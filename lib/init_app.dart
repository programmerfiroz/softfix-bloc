import 'package:flutter/material.dart';

import 'core/services/config/env_config.dart';
import 'core/services/storage/hive_storage.dart';
import 'core/services/storage/shared_prefs.dart';

Future<void> initApp() async {
  // Set environment configuration
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await EnvConfig.load();

  // Initialize local storage
  await SharedPrefs.init();
  await HiveStorage.init();

}
