import 'package:flutter/material.dart';

import 'services/api_service.dart';
import 'views/home_view.dart';

class CrmApp extends StatelessWidget {
  const CrmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRM Celular',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
      ),
      home: HomeView(apiService: ApiService()),
    );
  }
}
