import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'data/service/auth_service.dart';
import 'ui/di/di_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set default locale for the app
  Intl.defaultLocale = 'vi';
  await initializeDateFormatting('vi', null);

  // Initialize Dependency Injection
  configureDependencies();

  // Attempt to restore user session before running the app
  await getIt<AuthService>().initialize();

  runApp(const App());
}
