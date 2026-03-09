import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/ble_constants.dart';

class BluetoothService {
  BluetoothService({required Logger logger})
    : _logger = logger,
      _scanResultsController =
          StreamController<List<fbp.ScanResult>>.broadcast(),
      _connectionStateController =
          StreamController<fbp.BluetoothConnectionState>.broadcast();
  final Logger _logger;
  final StreamController<List<fbp.ScanResult>> _scanResultsController;
  final StreamController<fbp.BluetoothConnectionState>
  _connectionStateController;

  fbp.BluetoothDevice? _connectedDevice;
  StreamSubscription<List<fbp.ScanResult>>? _scanSubscription;
  StreamSubscription<fbp.BluetoothConnectionState>? _connectionSubscription;

  // Cache for discovered services to avoid repeated discovery
  final Map<String, List<fbp.BluetoothService>> _servicesCache = {};

  // Streams
  Stream<List<fbp.ScanResult>> get scanResults => _scanResultsController.stream;
  Stream<fbp.BluetoothConnectionState> get connectionState =>
      _connectionStateController.stream;

  // Getters
  fbp.BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _connectedDevice != null;

  // Request Bluetooth permissions
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final bluetoothScan = await Permission.bluetoothScan.request();
        final bluetoothConnect = await Permission.bluetoothConnect.request();
        final location = await Permission.location.request();

        final granted =
            bluetoothScan.isGranted &&
            bluetoothConnect.isGranted &&
            location.isGranted;

        if (!granted) {
          _logger.w('Bluetooth permissions not granted');
          return false;
        }
      } else if (Platform.isIOS) {
        final bluetooth = await Permission.bluetooth.request();
        if (!bluetooth.isGranted) {
          _logger.w('Bluetooth permission not granted on iOS');
          return false;
        }
      }

      return true;
    } on Exception catch (e) {
      _logger.e('Error requesting Bluetooth permissions: $e');
      return false;
    }
  }

  // Check if Bluetooth is available and enabled
  Future<bool> isBluetoothAvailable() async {
    try {
      if (Platform.isAndroid) {
        final isSupported = await fbp.FlutterBluePlus.isSupported;
        if (!isSupported) {
          _logger.w('Bluetooth not supported on this device');
          return false;
        }
      }

      final adapterState = await fbp.FlutterBluePlus.adapterState.first;
      return adapterState == fbp.BluetoothAdapterState.on;
    } on Exception catch (e) {
      _logger.e('Error checking Bluetooth availability: $e');
      return false;
    }
  }

  // Start scanning for devices
  Future<void> startScan({Duration? timeout}) async {
    try {
      final hasPermissions = await requestPermissions();
      if (!hasPermissions) {
        throw Exception('Bluetooth permissions not granted');
      }

      final isAvailable = await isBluetoothAvailable();
      if (!isAvailable) {
        throw Exception('Bluetooth is not available or not enabled');
      }

      _logger.i('Starting Bluetooth scan...');

      // Cancel previous scan if active
      await stopScan();

      // Start scanning
      await fbp.FlutterBluePlus.startScan(
        timeout: timeout ?? BleConstants.scanTimeout,
      );

      // Listen to scan results
      _scanSubscription = fbp.FlutterBluePlus.scanResults.listen(
        (results) {
          _logger.d('Found ${results.length} devices');
          _scanResultsController.add(results);
        },
        onError: (Object error) {
          _logger.e('Scan error: $error');
        },
      );
    } on Exception catch (e) {
      _logger.e('Error starting scan: $e');
      rethrow;
    }
  }

  // Stop scanning
  Future<void> stopScan() async {
    try {
      await fbp.FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      _logger.i('Bluetooth scan stopped');
    } on Exception catch (e) {
      _logger.e('Error stopping scan: $e');
    }
  }

  // Connect to a device
  Future<void> connect(fbp.BluetoothDevice device) async {
    try {
      _logger.i('Connecting to device: ${device.platformName}');

      // Disconnect from current device if any
      if (_connectedDevice != null) {
        await disconnect();
      }

      // Connect to the device
      await device.connect(
        license: fbp.License.free,
        timeout: BleConstants.connectionTimeout,
      );

      _connectedDevice = device;

      // Listen to connection state changes
      _connectionSubscription = device.connectionState.listen(
        (state) {
          _logger.d('Connection state changed: $state');
          _connectionStateController.add(state);

          if (state == fbp.BluetoothConnectionState.disconnected) {
            _logger.i(
              'Device ${device.remoteId} disconnected, clearing state.',
            );
            _servicesCache.remove(device.remoteId.toString());
            _connectedDevice = null;
            // Clean up the subscription itself to avoid zombie listeners
            _connectionSubscription?.cancel();
            _connectionSubscription = null;
          }
        },
        onError: (Object error) {
          _logger.e('Connection state error: $error');
        },
      );

      _logger.i('Connected to device: ${device.platformName}');

      // Pre-discover and cache services upon connection
      await discoverServicesForDevice(device);
    } on Exception catch (e) {
      _logger.e('Error connecting to device: $e');
      _connectedDevice = null;
      rethrow;
    }
  }

  // Disconnect from current device
  Future<void> disconnect() async {
    try {
      if (_connectedDevice != null) {
        final deviceId = _connectedDevice!.remoteId.toString();
        _logger.i(
          'Disconnecting from device: ${_connectedDevice!.platformName}',
        );
        await _connectedDevice!.disconnect();
        await _connectionSubscription?.cancel();
        _connectionSubscription = null;
        _connectedDevice = null;

        // Clear cache for the disconnected device
        _servicesCache.remove(deviceId);
        _logger.i('Disconnected successfully and cache cleared for $deviceId');
      }
    } on Exception catch (e) {
      _logger.e('Error disconnecting: $e');
    }
  }

  /// Discovers services for a specific device and caches them.
  /// Use this method instead of calling `device.discoverServices()` directly.
  Future<List<fbp.BluetoothService>> discoverServicesForDevice(
    fbp.BluetoothDevice device, {
    bool forceRefresh = false,
  }) async {
    final deviceId = device.remoteId.toString();

    // 1. Check cache first (unless forceRefresh is true)
    if (!forceRefresh && _servicesCache.containsKey(deviceId)) {
      _logger.d('Returning cached services for $deviceId');
      return _servicesCache[deviceId]!;
    }

    // 2. If not in cache or forceRefresh, discover, store, and return
    _logger.i(
      'Discovering services for $deviceId${forceRefresh ? ' (forced refresh)' : ''}...',
    );
    try {
      final services = await device.discoverServices();
      _servicesCache[deviceId] = services;
      _logger.i(
        'Discovered and cached ${services.length} services for $deviceId',
      );
      return services;
    } on Exception catch (e) {
      _logger.e('Error discovering services for $deviceId: $e');
      rethrow;
    }
  }

  /// @deprecated Use `discoverServicesForDevice(device)` instead.
  @Deprecated('Use discoverServicesForDevice(device) for caching')
  Future<List<fbp.BluetoothService>> discoverServices() {
    if (_connectedDevice == null) {
      throw Exception('No device connected');
    }
    return discoverServicesForDevice(_connectedDevice!);
  }

  // Read characteristic
  Future<List<int>> readCharacteristic(
    fbp.BluetoothCharacteristic characteristic,
  ) async {
    try {
      _logger.d('Reading characteristic: ${characteristic.uuid}');
      final value = await characteristic.read();
      _logger.d('Read value: ${utf8.decode(value, allowMalformed: true)}');
      return value;
    } on Exception catch (e) {
      _logger.e('Error reading characteristic: $e');
      rethrow;
    }
  }

  // Write characteristic
  Future<void> writeCharacteristic(
    fbp.BluetoothCharacteristic characteristic,
    List<int> value, {
    bool withoutResponse = false,
  }) async {
    try {
      _logger.d(
        'Writing to characteristic: ${characteristic.uuid} - Value: ${utf8.decode(value, allowMalformed: true)}',
      );
      await characteristic.write(value, withoutResponse: withoutResponse);
    } on Exception catch (e) {
      _logger.e('Error writing characteristic: $e');
      rethrow;
    }
  }

  // Subscribe to characteristic notifications
  StreamSubscription<List<int>> subscribeToCharacteristic(
    fbp.BluetoothCharacteristic characteristic,
    void Function(List<int>) onData,
  ) {
    try {
      _logger.d('Subscribing to characteristic: ${characteristic.uuid}');
      characteristic.setNotifyValue(true);
      return characteristic.lastValueStream.listen(onData);
    } on Exception catch (e) {
      _logger.e('Error subscribing to characteristic: $e');
      rethrow;
    }
  }

  // Get connected devices
  Future<List<fbp.BluetoothDevice>> getConnectedDevices() async {
    try {
      return fbp.FlutterBluePlus.connectedDevices;
    } on Exception catch (e) {
      _logger.e('Error getting connected devices: $e');
      return [];
    }
  }

  // Dispose resources
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _scanResultsController.close();
    _connectionStateController.close();
  }
}
