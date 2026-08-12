import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_app.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase Backend
  await Supabase.initialize(
    url: 'https://wuffiiruyprlotimcvif.supabase.co',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind1ZmZpaXJ1eXBybG90aW1jdmlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU4NzU5NzUsImV4cCI6MjEwMTQ1MTk3NX0.-7L5q1I6Ipx5LB0wquY-7cp3J6ebM8_krfpdFqZSDf0',
  );

  // Auto Sign-In Anonymously if no user is authenticated
  if (Supabase.instance.client.auth.currentUser == null) {
    try {
      await Supabase.instance.client.auth.signInAnonymously();
    } catch (e) {
      debugPrint('Admin Anonymous sign in error: $e');
    }
  }

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: BaytakAdminApp(),
    ),
  );
}
