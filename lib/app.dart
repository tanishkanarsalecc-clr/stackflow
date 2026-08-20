import 'package:flutter/material.dart';

import 'core/routes.dart';
import 'core/theme.dart';

class StackFlowApp extends StatelessWidget {
  const StackFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StackFlow',
      theme: StackFlowTheme.lightTheme,
      initialRoute: AppRoutes.auth,
      routes: AppRoutes.routes,
    );
  }
}