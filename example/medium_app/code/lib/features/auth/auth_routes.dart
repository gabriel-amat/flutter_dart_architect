import 'package:flutter/material.dart';
import '../../core/navigation/app_pages.dart';
import 'presentation/pages/login_page.dart';

final authRoutes = <String, WidgetBuilder>{
  AppPages.login: (_) => const LoginPage(),
};
