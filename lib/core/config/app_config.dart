class AppConfig {
  const AppConfig._();

  static const String tenantId = String.fromEnvironment(
    'TENANT_ID',
    defaultValue: 'default',
  );

  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Wasla',
  );
}
