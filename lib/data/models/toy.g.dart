// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Toy _$ToyFromJson(Map<String, dynamic> json) => _Toy(
  id: json['id'] as String,
  name: json['name'] as String,
  status: $enumDecode(_$ToyStatusEnumMap, json['status']),
  iotDeviceId: json['iotDeviceId'] as String?,
  iotDeviceStatus: json['iotDeviceStatus'] as String?,
  userId: json['userId'] as String?,
  model: json['model'] as String?,
  manufacturer: json['manufacturer'] as String?,
  firmwareVersion: json['firmwareVersion'] as String?,
  capabilities: json['capabilities'] as Map<String, dynamic>?,
  settings: json['settings'] as Map<String, dynamic>?,
  notes: json['notes'] as String?,
  prompt: json['prompt'] as String?,
  personalityProfile: json['personalityProfile'] as String?,
  greeting: json['greeting'] as String?,
  batteryLevel: json['batteryLevel'] as String?,
  signalStrength: json['signalStrength'] as String?,
  lastConnected: json['lastSeenAt'] == null
      ? null
      : DateTime.parse(json['lastSeenAt'] as String),
  activatedAt: json['activatedAt'] == null
      ? null
      : DateTime.parse(json['activatedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ToyToJson(_Toy instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'status': _$ToyStatusEnumMap[instance.status]!,
  'iotDeviceId': instance.iotDeviceId,
  'iotDeviceStatus': instance.iotDeviceStatus,
  'userId': instance.userId,
  'model': instance.model,
  'manufacturer': instance.manufacturer,
  'firmwareVersion': instance.firmwareVersion,
  'capabilities': instance.capabilities,
  'settings': instance.settings,
  'notes': instance.notes,
  'prompt': instance.prompt,
  'personalityProfile': instance.personalityProfile,
  'greeting': instance.greeting,
  'batteryLevel': instance.batteryLevel,
  'signalStrength': instance.signalStrength,
  'lastSeenAt': instance.lastConnected?.toIso8601String(),
  'activatedAt': instance.activatedAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$ToyStatusEnumMap = {
  ToyStatus.active: 'active',
  ToyStatus.inactive: 'inactive',
  ToyStatus.connected: 'connected',
  ToyStatus.disconnected: 'disconnected',
  ToyStatus.maintenance: 'maintenance',
  ToyStatus.error: 'error',
  ToyStatus.blocked: 'blocked',
  ToyStatus.pending: 'pending',
};

_CreateToyRequest _$CreateToyRequestFromJson(Map<String, dynamic> json) =>
    _CreateToyRequest(
      deviceId: json['deviceId'] as String?,
      macAddress: json['macAddress'] as String?,
      name: json['name'] as String,
      model: json['model'] as String?,
      manufacturer: json['manufacturer'] as String?,
      status: $enumDecodeNullable(_$ToyStatusEnumMap, json['status']),
      firmwareVersion: json['firmwareVersion'] as String?,
      capabilities: json['capabilities'] as Map<String, dynamic>?,
      settings: json['settings'] as Map<String, dynamic>?,
      notes: json['notes'] as String?,
      prompt: json['prompt'] as String?,
      personalityProfile: json['personalityProfile'] as String?,
      greeting: json['greeting'] as String?,
    );

Map<String, dynamic> _$CreateToyRequestToJson(_CreateToyRequest instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'macAddress': instance.macAddress,
      'name': instance.name,
      'model': instance.model,
      'manufacturer': instance.manufacturer,
      'status': _$ToyStatusEnumMap[instance.status],
      'firmwareVersion': instance.firmwareVersion,
      'capabilities': instance.capabilities,
      'settings': instance.settings,
      'notes': instance.notes,
      'prompt': instance.prompt,
      'personalityProfile': instance.personalityProfile,
      'greeting': instance.greeting,
    };

_AssignToyRequest _$AssignToyRequestFromJson(Map<String, dynamic> json) =>
    _AssignToyRequest(
      macAddress: json['macAddress'] as String?,
      deviceId: json['deviceId'] as String?,
      userId: json['userId'] as String,
      toyName: json['toyName'] as String?,
    );

Map<String, dynamic> _$AssignToyRequestToJson(_AssignToyRequest instance) =>
    <String, dynamic>{
      'macAddress': instance.macAddress,
      'deviceId': instance.deviceId,
      'userId': instance.userId,
      'toyName': instance.toyName,
    };

_AssignToyResponse _$AssignToyResponseFromJson(Map<String, dynamic> json) =>
    _AssignToyResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      toy: json['toy'] == null
          ? null
          : Toy.fromJson(json['toy'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AssignToyResponseToJson(_AssignToyResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'toy': instance.toy,
    };

_UpdateToyStatusRequest _$UpdateToyStatusRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateToyStatusRequest(
  status: $enumDecode(_$ToyStatusEnumMap, json['status']),
  batteryLevel: json['batteryLevel'] as String?,
  signalStrength: json['signalStrength'] as String?,
);

Map<String, dynamic> _$UpdateToyStatusRequestToJson(
  _UpdateToyStatusRequest instance,
) => <String, dynamic>{
  'status': _$ToyStatusEnumMap[instance.status]!,
  'batteryLevel': instance.batteryLevel,
  'signalStrength': instance.signalStrength,
};
