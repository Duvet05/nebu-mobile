enum SetupFlowMode { onboarding, changeWifi }

class ConnectionSetupRouteArgs {
  const ConnectionSetupRouteArgs({
    this.mode = SetupFlowMode.onboarding,
    this.returnRoute,
    this.returnExtra,
  });

  final SetupFlowMode mode;
  final String? returnRoute;
  final Object? returnExtra;
}

class WifiSetupRouteArgs {
  const WifiSetupRouteArgs({
    this.webBleService,
    this.mode = SetupFlowMode.onboarding,
    this.returnRoute,
    this.returnExtra,
  });

  final Object? webBleService;
  final SetupFlowMode mode;
  final String? returnRoute;
  final Object? returnExtra;
}
