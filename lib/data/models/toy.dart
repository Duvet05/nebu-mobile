import 'package:freezed_annotation/freezed_annotation.dart';

part 'toy.freezed.dart';
part 'toy.g.dart';

enum ToyStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('connected')
  connected,
  @JsonValue('disconnected')
  disconnected,
  @JsonValue('maintenance')
  maintenance,
  @JsonValue('error')
  error,
  @JsonValue('blocked')
  blocked,
  @JsonValue('pending')
  pending,
}

@freezed
abstract class Toy with _$Toy {
  const factory Toy({
    required String id,
    required String name,
    required ToyStatus status,
    String? iotDeviceId,
    String? iotDeviceStatus,
    String? userId,
    String? ownerId,
    String? model,
    String? manufacturer,
    String? firmwareVersion,
    Map<String, dynamic>? capabilities,
    Map<String, dynamic>? settings,
    String? notes,
    String? prompt,
    String? personalityProfile,
    String? greeting,
    String? batteryLevel,
    String? signalStrength,
    @JsonKey(name: 'lastSeenAt') DateTime? lastConnected,
    DateTime? activatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Toy;

  factory Toy.fromJson(Map<String, dynamic> json) => _$ToyFromJson(json);
}

@freezed
abstract class CreateToyRequest with _$CreateToyRequest {
  const factory CreateToyRequest({
    required String name,
    String? deviceId,
    String? macAddress,
    String? model,
    String? manufacturer,
    ToyStatus? status,
    String? firmwareVersion,
    Map<String, dynamic>? capabilities,
    Map<String, dynamic>? settings,
    String? notes,
    String? prompt,
    String? personalityProfile,
    String? greeting,
  }) = _CreateToyRequest;

  factory CreateToyRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateToyRequestFromJson(json);
}

@freezed
abstract class AssignToyRequest with _$AssignToyRequest {
  const factory AssignToyRequest({
    required String userId,
    String? macAddress,
    String? deviceId,
    String? toyName,
  }) = _AssignToyRequest;

  factory AssignToyRequest.fromJson(Map<String, dynamic> json) =>
      _$AssignToyRequestFromJson(json);
}

@freezed
abstract class AssignToyResponse with _$AssignToyResponse {
  const factory AssignToyResponse({
    required bool success,
    String? message,
    Toy? toy,
  }) = _AssignToyResponse;

  factory AssignToyResponse.fromJson(Map<String, dynamic> json) =>
      _$AssignToyResponseFromJson(json);
}

@freezed
abstract class UpdateToyStatusRequest with _$UpdateToyStatusRequest {
  const factory UpdateToyStatusRequest({
    required ToyStatus status,
    String? batteryLevel,
    String? signalStrength,
  }) = _UpdateToyStatusRequest;

  factory UpdateToyStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateToyStatusRequestFromJson(json);
}
