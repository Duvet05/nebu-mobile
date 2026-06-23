# Nebu Mobile App 🧸

**Aplicación móvil para configuración y gestión de juguetes inteligentes con ESP32**

Nebu Mobile es una aplicación Flutter que permite a los usuarios configurar y gestionar juguetes inteligentes equipados con ESP32. La app facilita la conexión WiFi del dispositivo, el seguimiento de actividades del usuario, y la integración con servicios de IA a través de LiveKit Cloud.

---

## 🎯 Objetivo Principal

La aplicación tiene como propósito principal:

1. **Configuración de Juguetes ESP32**: Proporcionar credenciales WiFi a peluches con ESP32 mediante Bluetooth Low Energy
2. **Tracking de Actividades**: Registrar automáticamente las interacciones del usuario (conexiones, comandos de voz, sesiones de juego)
3. **Gestión de Usuario**: Permitir uso sin cuenta (UUID local) con migración automática al crear cuenta
4. **Integración LiveKit**: El ESP32 se conecta directamente a LiveKit Cloud para procesamiento de voz
5. **Dashboard IoT**: Visualizar y gestionar dispositivos conectados

---

## ⚙️ Configuración Inicial

### 1. Setup de Configuracion

```bash
# Desarrollo local con defaults de produccion
flutter run

# Override opcional por dart-define
flutter run --dart-define=ENV=development --dart-define=API_URL=https://api.flow-telligence.com/api/v1
```

Ver **[docs/production-release.md](docs/production-release.md)** para:
- Builds de produccion con `--dart-define`
- GitHub Variables/Secrets
- Firebase Android/iOS
- Publicacion a Play Store

### 2. Instalar Dependencias

```bash
flutter pub get
```

### 3. Ejecutar en Desarrollo

```bash
# Opción 1: Script recomendado
./scripts/run_dev.sh

# Opción 2: Comando Flutter
flutter run --dart-define=ENV=development
```

---

## 🚀 Características Principales

### ✅ Implementadas

- **Setup Wizard Completo** (7 pasos)
  - Configuración sin cuenta (UUID local)
  - Conexión Bluetooth con ESP32
  - Configuración WiFi del dispositivo
  - Personalización del toy
  
- **Activity Tracking System**
  - ✅ Tracking automático de conexiones/desconexiones Bluetooth
  - ✅ Sistema de UUID para usuarios sin cuenta
  - ✅ Migración automática de actividades (UUID → userId) al crear cuenta
  - ✅ Activity Log con paginación
  - ✅ Integración con backend (GET/POST /activities, /activities/migrate)
  
- **Authentication**
  - Login/Register con email
  - Google Sign In
  - Facebook Login
  - Apple Sign In
  - Migración automática de datos al autenticarse

- **Bluetooth LE**
  - Escaneo de dispositivos ESP32
  - Conexión segura
  - Envío de credenciales WiFi
  - Tracking automático de conexión/desconexión

- **IoT Management**
  - Dashboard de dispositivos
  - Estado de conexión
  - Gestión de toys

### 🔄 En Progreso / Pendientes

- **Voice Commands Tracking** (Requiere backend webhook)
  - ⏳ Backend: Webhook de LiveKit para recibir transcripciones
  - ⏳ ESP32: Enviar userId en room metadata
  - ✅ Mobile: Método `trackVoiceCommand()` implementado
  
- **Error Tracking**
  - ❌ GlobalErrorHandler pendiente
  - ❌ Tracking automático de errores BT/API
  
- **Play Sessions Tracking**
  - ❌ Integración en screens de interacción
  
- **Activity Stats UI**
  - ❌ Widget de estadísticas en dashboard
  
- **Chat with AI Tracking**
  - ❌ Tracking de mensajes de chat

---

## 📱 Flujo Principal de Usuario

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRIMERA VEZ (Sin cuenta)                     │
└─────────────────────────────────────────────────────────────────┘
1. Usuario abre la app → Genera UUID local automáticamente
2. Completa Setup Wizard (7 pasos) → Activity registrada con UUID
3. Conecta toy por Bluetooth → Activity de conexión con UUID
4. Configura WiFi del ESP32 → ESP32 se conecta a LiveKit Cloud
5. Usuario usa el toy → Todas las activities se guardan con UUID

┌─────────────────────────────────────────────────────────────────┐
│              USUARIO CREA CUENTA (Migración)                    │
└─────────────────────────────────────────────────────────────────┘
6. Usuario crea cuenta / login → AuthProvider detecta UUID local
7. Migración automática → POST /activities/migrate {UUID → userId}
8. Todas las activities históricas ahora pertenecen al userId real
9. Usuario sigue usando con userId autenticado

┌─────────────────────────────────────────────────────────────────┐
│                  COMANDOS DE VOZ (ESP32)                        │
└─────────────────────────────────────────────────────────────────┘
10. Usuario habla al peluche
11. ESP32 procesa audio → LiveKit Cloud (directo)
12. LiveKit transcribe → Envía webhook a backend
13. Backend crea activity tipo 'voice_command'
14. App muestra en Activity Log
```

---

## 📱 Pantallas Principales

- **Splash Screen** - Pantalla de bienvenida con branding
- **Setup Wizard** - Configuración inicial de 7 pasos
- **Home** - Dashboard principal con acciones rápidas
- **IoT Dashboard** - Gestión de dispositivos IoT
- **Voice Agent** - Asistente de voz con IA
- **Profile** - Configuración de usuario
- **QR Scanner** - Escáner para dispositivos

## 🛠️ Tecnologías

### Core
- **Flutter 3.27.3** - Framework principal
- **Dart 3.6.1** - Lenguaje de programación

### State Management
- **Riverpod 2.5.1** - Gestión de estado reactiva
- **Get 4.6.6** - Navegación y dependencias

### Networking & API
- **Dio 5.4.3** - Cliente HTTP
- **Retrofit 4.1.0** - Generación de APIs

### Storage
- **SharedPreferences 2.2.3** - Almacenamiento local
- **Flutter Secure Storage 9.0.0** - Almacenamiento seguro

### Authentication
- **Google Sign In 6.2.1** - Autenticación con Google
- **Sign in with Apple 6.1.0** - Autenticación con Apple
- **Flutter Facebook Auth 7.0.1** - Autenticación con Facebook

### Hardware & Permissions
- **Flutter Blue Plus 1.32.11** - Bluetooth Low Energy
- **Permission Handler 11.3.1** - Manejo de permisos
- **Camera 0.11.0+1** - Acceso a cámara

### Audio & Voice
- **AudioPlayers 6.0.0** - Reproducción de audio
- **Just Audio 0.9.37** - Audio streaming
- **Record 5.1.0** - Grabación de audio

### AI & Communication
- **LiveKit Client 2.1.2** - WebRTC y comunicación en tiempo real
- **Dart OpenAI 5.1.0** - Integración con OpenAI

### UI & UX
- **Cached Network Image 3.3.1** - Carga optimizada de imágenes
- **Shimmer 3.0.0** - Efectos de carga
- **Flutter SVG 2.0.10+1** - Soporte para SVG

## � TODOs Prioritarios

### 🔴 Alta Prioridad (Core Functionality)

#### 1. Voice Commands Backend (⏳ Requiere Backend)
**Objetivo**: Trackear comandos de voz procesados por ESP32 + LiveKit

**Tareas Backend**:
- [ ] Implementar webhook endpoint `POST /api/v1/webhooks/livekit`
- [ ] Configurar webhook URL en LiveKit Cloud Dashboard
- [ ] Crear activities tipo 'voice_command' desde webhook
- [ ] Verificar firma de webhook (HMAC-SHA256)
- [ ] Agregar `LIVEKIT_WEBHOOK_SECRET` a las variables del backend

**Tareas ESP32**:
- [ ] Enviar `userId` y `toyId` en room metadata al conectar
- [ ] Verificar formato de metadata

**Arquitectura**:
```
Usuario → ESP32 → LiveKit Cloud → Backend Webhook → Activity DB
```

**Referencia**: Ver especificación completa en commit anterior (archivo eliminado)

#### 2. Error Tracking (Mobile)
**Objetivo**: Registrar errores automáticamente

**Tareas**:
- [ ] Crear `GlobalErrorHandler` service
- [ ] Integrar en try-catch de BluetoothService
- [ ] Integrar en try-catch de API calls
- [ ] Integrar en toy communication errors
- [ ] Agregar a error boundary widgets

**Código Sugerido**:
```dart
class GlobalErrorHandler {
  static Future<void> handleError(
    dynamic error, 
    {String? toyId, StackTrace? stackTrace}
  ) async {
    logger.e('Error: $error', error: error, stackTrace: stackTrace);
    
    await activityTracker.trackError(
      error.toString(),
      toyId: toyId,
      errorDetails: {
        'timestamp': DateTime.now().toIso8601String(),
        'stack_trace': stackTrace?.toString(),
        'error_type': error.runtimeType.toString(),
      },
    );
  }
}
```

### 🟡 Media Prioridad (User Engagement)

#### 3. Play Sessions Tracking
**Objetivo**: Registrar cuando el usuario inicia interacción con toy

**Tareas**:
- [ ] Identificar screens de interacción con toys
- [ ] Agregar `trackPlaySessionStart()` en initState()
- [ ] Opcional: trackear duración de sesión

#### 4. Chat with AI Tracking
**Objetivo**: Registrar conversaciones con el AI

**Tareas**:
- [ ] Identificar servicio/screen de chat
- [ ] Agregar `trackChatMessage()` para mensajes del usuario
- [ ] Agregar `trackChatMessage()` para respuestas del AI

### 🟢 Baja Prioridad (Polish)

#### 5. Activity Stats Dashboard
**Objetivo**: Visualizar estadísticas de actividades

**Tareas**:
- [ ] Crear `ActivityStatsWidget`
- [ ] Agregar al dashboard/home screen
- [ ] Mostrar: total activities, por tipo, última actividad
- [ ] Opcional: Gráficos de actividad por día/semana

#### 6. Sleep/Wake Tracking (Si aplica)
**Tareas**:
- [ ] Verificar si toys tienen estados sleep/wake
- [ ] Integrar `trackSleep()` y `trackWake()`

---

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── constants/          # Constantes (BLE, storage keys, etc.)
│   ├── router/            # Go Router - navegación
│   ├── theme/             # Temas claro/oscuro
│   └── utils/             # Utilidades y env config
├── data/
│   ├── models/            # Modelos Freezed (Activity, User, Toy, IoT)
│   ├── repositories/      # Repositorios (sin usar aún)
│   └── services/          # ⭐ SERVICIOS PRINCIPALES
│       ├── activity_service.dart              # HTTP activities
│       ├── activity_tracker_service.dart      # ⭐ Auto-tracking
│       ├── activity_migration_service.dart    # ⭐ UUID → userId
│       ├── bluetooth_service.dart             # BLE ESP32
│       ├── livekit_service.dart               # LiveKit client
│       ├── auth_service.dart                  # Authentication
│       ├── toy_service.dart                   # Toy CRUD
│       ├── iot_service.dart                   # IoT devices
│       └── user_setup_service.dart            # Setup flow
├── presentation/
│   ├── providers/         # Riverpod providers
│   │   ├── activity_provider.dart             # ActivityNotifier
│   │   ├── auth_provider.dart                 # ⭐ Con migración
│   │   ├── bluetooth_connection_listener_provider.dart  # ⭐ Auto-tracking BT
│   │   └── ...
│   ├── screens/           
│   │   ├── setup/                             # Setup Wizard (7 pasos)
│   │   ├── activity_log_screen.dart           # ⭐ Activity Log UI
│   │   ├── my_toys_screen.dart
│   │   └── ...
│   └── widgets/           # Componentes reutilizables
└── assets/
    └── translations/      # i18n (en.json, es.json)
```

**⭐ = Archivos clave para Activity Tracking**

---

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK 3.27.3 o superior
- Dart SDK 3.6.1 o superior
- Android Studio / Xcode
- Git

### Pasos de instalación

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd nebu-mobile
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Generar código**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Configurar variables de build**
```bash
flutter run --dart-define=ENV=development
```

5. **Ejecutar la aplicación**
```bash
# Para desarrollo
flutter run

# Para release
flutter run --release
```

## 🏗️ Arquitectura del Sistema

### Componentes Principales

```
┌─────────────────────────────────────────────────────────────────┐
│                         MOBILE APP                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Bluetooth   │  │   Activity   │  │     Auth     │          │
│  │   Service    │  │   Tracker    │  │   Provider   │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         │                  │                  │                  │
└─────────┼──────────────────┼──────────────────┼──────────────────┘
          │                  │                  │
          ▼                  ▼                  ▼
    ┌──────────┐      ┌──────────┐      ┌──────────┐
    │  ESP32   │      │ Backend  │      │ Backend  │
    │  Toy     │      │   API    │      │   API    │
    └────┬─────┘      └──────────┘      └──────────┘
         │
         │ (WiFi)
         ▼
   ┌──────────────┐
   │ LiveKit Cloud│
   │              │
   │  • Voice AI  │
   │  • Webhooks  │──────────────┐
   └──────────────┘              │
                                 ▼
                          ┌──────────┐
                          │ Backend  │
                          │ Webhook  │
                          └──────────┘
```

### Flujos de Datos

1. **Setup & Conexión**:
   - App → Bluetooth → ESP32 (credenciales WiFi)
   - ESP32 → WiFi → LiveKit Cloud

2. **Activity Tracking**:
   - App → Backend API → Activity DB (conexiones, setup)
   - ESP32 → LiveKit → Backend Webhook → Activity DB (voz)

3. **Authentication & Migration**:
   - App → Backend API (login/register)
   - Backend API → Migración de activities (UUID → userId)

---

## 🔧 Configuración de Desarrollo

### Variables de Build
La app no carga `.env`. Para overrides locales usa `--dart-define`:

```bash
flutter run \
  --dart-define=ENV=development \
  --dart-define=API_URL=https://api.flow-telligence.com/api/v1 \
  --dart-define=LIVEKIT_URL=wss://livekit.flow-telligence.com
```

### Variables Backend (Requiere implementar)
Estas variables van en el backend, no en la app movil:

```env
# LiveKit Webhook
LIVEKIT_WEBHOOK_SECRET=your_webhook_secret_from_livekit_dashboard

# LiveKit server credentials
LIVEKIT_API_KEY=your_livekit_api_key
LIVEKIT_API_SECRET=your_livekit_secret

# Database
MONGODB_URI=your_mongodb_uri

# JWT
JWT_SECRET=your_jwt_secret

# AI
OPENAI_API_KEY=your_openai_api_key
```

### Permisos Android
Agregar en `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### Permisos iOS
Agregar en `ios/Runner/Info.plist`:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth for device connection</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for QR scanning</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone for voice commands</string>
```

## 🧪 Testing

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/
```

## 📦 Build

### Android
```bash
# Debug APK



# Release APK
flutter build apk --release

# App Bundle (recomendado para Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build para iOS
flutter build ios --release
```

## 📊 Estado del Proyecto

### Features Core
```
✅ Sistema Base:              100% (services, UI, migration)
✅ Bluetooth Tracking:        100% (auto-tracking implementado)
✅ Auth Integration:          100% (migración automática)
⏳ Voice Commands:             33% (mobile listo, falta backend webhook)
✅ Error Tracking:            100% (Crashlytics + GlobalErrorHandlers)
❌ Play Sessions:               0% (pendiente integración)
❌ Chat Tracking:               0% (pendiente identificar servicio)
❌ Activity Stats UI:           0% (pendiente widget)
```

**Total Implementado**: 6/11 funcionalidades = **54.5%** ✅

### Tracking de Actividades (Mobile)
- ✅ `trackToyConnection()` / `trackToyDisconnection()` - **Implementado**
- ✅ `trackSetupCompleted()` - **Implementado**
- ✅ `trackVoiceCommand()` - ⏳ Listo (falta webhook backend)
- ✅ `trackError()` - **Implementado** (ErrorReportingService + Crashlytics)
- ❌ `trackPlaySessionStart()` - Método existe, falta integración
- ❌ `trackInteraction()` - Método existe, sin uso
- ❌ `trackChatMessage()` - Método existe, sin uso
- ❌ `trackSleep()` / `trackWake()` - Métodos existen, sin uso
- ❌ `trackUpdate()` - Método existe, sin uso

---

## 🎯 Próximos Pasos

### Para el Equipo Backend
1. **⏳ Implementar webhook de LiveKit** (Alta prioridad)
   - Endpoint: `POST /api/v1/webhooks/livekit`
   - Eventos: `transcription.received`, `speech.completed`
   - Crear activities tipo `voice_command` automáticamente
   - Ver especificación en commit anterior

2. **✅ Verificar ESP32 metadata**
   - Asegurar que ESP32 envíe `userId` en room metadata
   - Formato: `{ userId: "...", toyId: "...", deviceId: "..." }`

### Para el Equipo Mobile
1. **❌ Implementar GlobalErrorHandler** (Media prioridad)
2. **❌ Integrar tracking de play sessions** (Media prioridad)
3. **❌ Crear Activity Stats Widget** (Baja prioridad)

---

## 🤝 Contribución

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

---

## � Contacto

- **Repository**: [NEBUAI/nebu-mobile](https://github.com/NEBUAI/nebu-mobile)
- **Branch**: BLE-sonido
- **Backend API**: https://api.flow-telligence.com/api/v1

---

**Desarrollado con ❤️ por NEBUAI usando Flutter**
