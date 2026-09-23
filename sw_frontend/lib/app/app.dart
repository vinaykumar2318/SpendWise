import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SpendWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
