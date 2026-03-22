import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'controllers/auth_controller.dart';
import 'controllers/activity_controller.dart';
import 'views/login_page.dart';

void main() {
  runApp(const StrideApp());
}

// Widget raiz do aplicativo
// MultiProvider injeta os controllers na árvore de widgets,
// tornando-os acessíveis em qualquer tela via Provider.of ou Consumer
class StrideApp extends StatelessWidget {
  const StrideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Registra os ChangeNotifierProviders para gerenciamento de estado
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ActivityController()),
      ],
      child: MaterialApp(
        title: 'Stride',
        debugShowCheckedModeBanner: false,
        // Configuração de localização para português (DatePicker, etc.)
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
        ],
        locale: const Locale('pt', 'BR'),
        // Tema global do aplicativo
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        home: const LoginPage(),
      ),
    );
  }
}
