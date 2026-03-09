import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../providers/api_provider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  List<_Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(orderServiceProvider);
      final data = await service.getMyOrders();
      if (!mounted) {
        return;
      }
      setState(() {
        _orders = data.map(_Order.fromJson).toList();
        _isLoading = false;
      });
    } on Exception {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(title: Text('orders.title'.tr()), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? _buildEmptyState(theme)
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: EdgeInsets.all(context.spacing.alertPadding),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return _OrderCard(order: order);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.shopping_bag_outlined,
          size: 100,
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
        SizedBox(height: context.spacing.panelPadding),
        Text(
          'orders.no_orders'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: context.spacing.titleBottomMarginSm),
        Text(
          'orders.no_orders_desc'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final _Order order;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final total = order.totalPrice;

    return Card(
      margin: EdgeInsets.only(bottom: context.spacing.sectionTitleBottomMargin),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: context.radius.modal),
      child: InkWell(
        onTap: () => _showOrderDetails(context, order),
        borderRadius: context.radius.panel,
        child: Padding(
          padding: EdgeInsets.all(context.spacing.alertPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(order.status, context),
                ],
              ),
              SizedBox(height: context.spacing.titleBottomMarginSm),

              // Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(order.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing.paragraphBottomMarginSm),

              const Divider(),
              SizedBox(height: context.spacing.paragraphBottomMarginSm),

              // Items
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity}x ${item.name}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '\$${item.subtotal.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(),
              SizedBox(height: context.spacing.paragraphBottomMarginSm),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'orders.total'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, BuildContext context) {
    Color color;
    String label;

    switch (status.toUpperCase()) {
      case 'DELIVERED':
        color = context.colors.success;
        label = 'orders.status_delivered'.tr();
      case 'SHIPPED':
        color = context.colors.info;
        label = 'orders.status_shipped'.tr();
      case 'PROCESSING':
      case 'CONFIRMED':
        color = context.colors.warning;
        label = 'orders.status_processing'.tr();
      case 'CANCELLED':
        color = context.colors.error;
        label = 'orders.status_cancelled'.tr();
      case 'PENDING':
      case 'RESERVED':
        color = context.colors.warning100;
        label = 'orders.status_processing'.tr();
      default:
        color = context.colors.grey400;
        label = status;
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'orders.today'.tr();
    } else if (difference.inDays == 1) {
      return 'orders.yesterday'.tr();
    } else if (difference.inDays < 7) {
      return 'orders.days_ago'.tr(args: [difference.inDays.toString()]);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  void _showOrderDetails(BuildContext context, _Order order) {
    unawaited(showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _OrderDetailsSheet(order: order),
    ));
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  const _OrderDetailsSheet({required this.order});

  final _Order order;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final total = order.totalPrice;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.all(context.spacing.pageMargin),
        child: ListView(
          controller: scrollController,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.grey700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: context.spacing.panelPadding),

            // Title
            Text(
              'orders.order_details'.tr(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.spacing.titleBottomMarginSm),
            Text(
              order.orderNumber,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: context.spacing.panelPadding),

            // Status timeline
            _buildStatusTimeline(context),
            SizedBox(height: context.spacing.panelPadding),

            // Items
            Text(
              'orders.items'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.spacing.paragraphBottomMarginSm),
            ...order.items.map((item) => _buildItemRow(context, item, theme)),
            const Divider(height: 32),

            // Summary
            _buildSummaryRow('orders.subtotal'.tr(), total, theme),
            _buildSummaryRow('orders.shipping'.tr(), 0, theme),
            _buildSummaryRow('orders.tax'.tr(), total * 0.1, theme),
            const Divider(height: 32),
            _buildSummaryRow(
              'orders.total'.tr(),
              total + (total * 0.1),
              theme,
              bold: true,
            ),

            SizedBox(height: context.spacing.panelPadding),

            // Actions
            if (order.status.toUpperCase() != 'CANCELLED' &&
                order.status.toUpperCase() != 'DELIVERED')
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('orders.track_order_coming_soon'.tr()),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: context.radius.tile,
                  ),
                ),
                child: Text('orders.track_order'.tr()),
              ),
            SizedBox(height: context.spacing.paragraphBottomMarginSm),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('orders.support_coming_soon'.tr())),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: context.radius.tile,
                ),
              ),
              child: Text('orders.contact_support'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(BuildContext context) {
    final theme = context.theme;
    final upperStatus = order.status.toUpperCase();
    final statusOrder = ['PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED'];
    final currentIndex = statusOrder.indexOf(upperStatus);

    return Container(
      padding: EdgeInsets.all(context.spacing.alertPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: context.radius.tile,
      ),
      child: Column(
        children: [
          _buildTimelineItem(
            'orders.timeline_placed'.tr(),
            currentIndex >= 0,
            context,
            isFirst: true,
          ),
          _buildTimelineItem(
            'orders.timeline_processing'.tr(),
            currentIndex >= 1,
            context,
          ),
          _buildTimelineItem(
            'orders.timeline_shipped'.tr(),
            currentIndex >= 2,
            context,
          ),
          _buildTimelineItem(
            'orders.timeline_delivered'.tr(),
            currentIndex >= 3,
            context,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String label,
    bool completed,
    BuildContext context, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final theme = context.theme;
    return Row(
    children: [
      Column(
        children: [
          if (!isFirst)
            Container(
              width: 2,
              height: 20,
              color: completed
                  ? theme.colorScheme.primary
                  : context.colors.grey400.withValues(alpha: 0.3),
            ),
          Icon(
            completed ? Icons.check_circle : Icons.circle_outlined,
            color: completed
                ? theme.colorScheme.primary
                : context.colors.grey400.withValues(alpha: 0.5),
            size: 24,
          ),
          if (!isLast)
            Container(
              width: 2,
              height: 20,
              color: completed
                  ? theme.colorScheme.primary
                  : context.colors.grey400.withValues(alpha: 0.3),
            ),
        ],
      ),
      const SizedBox(width: 16),
      Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: completed
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: completed ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    ],
  );
  }

  Widget _buildItemRow(BuildContext context, _OrderItem item, ThemeData theme) => Padding(
    padding: EdgeInsets.only(bottom: context.spacing.paragraphBottomMarginSm),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: theme.textTheme.bodyMedium),
              Text(
                'orders.quantity'.tr(args: [item.quantity.toString()]),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Text(
          '\$${item.subtotal.toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Widget _buildSummaryRow(
    String label,
    double amount,
    ThemeData theme, {
    bool bold = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

class _Order {
  _Order({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.status,
    required this.totalPrice,
    required this.items,
  });

  factory _Order.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return _Order(
      id: json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? json['id'] as String? ?? '',
      date: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      status: json['status'] as String? ?? 'PENDING',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ??
          (json['totalAmount'] as num?)?.toDouble() ??
          0,
      items: itemsList
          .map((e) => _OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String id;
  final String orderNumber;
  final DateTime date;
  final String status;
  final double totalPrice;
  final List<_OrderItem> items;
}

class _OrderItem {
  _OrderItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory _OrderItem.fromJson(Map<String, dynamic> json) {
    final quantity = json['quantity'] as int? ?? 1;
    final unitPrice = (json['unitPrice'] as num?)?.toDouble() ?? 0;
    return _OrderItem(
      name: json['productName'] as String? ??
          (json['product'] as Map<String, dynamic>?)?['name'] as String? ??
          'Item',
      quantity: quantity,
      unitPrice: unitPrice,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? unitPrice * quantity,
    );
  }

  final String name;
  final int quantity;
  final double unitPrice;
  final double subtotal;
}
