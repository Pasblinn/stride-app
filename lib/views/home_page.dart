import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/activity_controller.dart';
import 'activity_feed_page.dart';
import 'add_activity_page.dart';
import 'profile_page.dart';
import 'stats_page.dart';

// Tela principal com navegação por BottomNavigationBar
// Gerencia a troca entre as abas do aplicativo
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Lista de páginas correspondentes a cada aba da navegação
  final List<Widget> _pages = const [
    ActivityFeedPage(),
    StatsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Carrega as atividades do usuário logado ao iniciar a página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController =
          Provider.of<AuthController>(context, listen: false);
      if (authController.currentUser != null) {
        Provider.of<ActivityController>(context, listen: false)
            .loadActivities(authController.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      // FloatingActionButton central para adicionar nova atividade
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddActivityPage()),
          );
        },
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Barra de navegação inferior com 3 abas
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Atividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estatísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
