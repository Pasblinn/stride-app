import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'controllers/auth_controller.dart';
import 'controllers/activity_controller.dart';
import 'views/login_page.dart';
import 'views/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        // SplashPage verifica se há sessão salva antes de decidir a tela inicial
        home: const SplashPage(),
      ),
    );
  }
}

// Tela de carregamento inicial que verifica a sessão salva
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final authController =
        Provider.of<AuthController>(context, listen: false);
    final isLoggedIn = await authController.tryAutoLogin();

    if (!mounted) return;

    if (isLoggedIn) {
      // Sessão encontrada, vai direto para a Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      // Sem sessão, vai para o Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tela de loading enquanto verifica a sessão
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_run, size: 80, color: Colors.deepOrange),
            SizedBox(height: 16),
            Text(
              'Stride',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.deepOrange),
          ],
        ),
      ),
    );
  }
}
