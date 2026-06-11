import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/activity_controller.dart';
import 'activity_feed_page.dart';
import 'add_activity_page.dart';
import 'profile_page.dart';
import 'stats_page.dart';
import 'tracking_page.dart';

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
      if (authController.token != null) {
        Provider.of<ActivityController>(context, listen: false)
            .loadActivities(token: authController.token!);
      }
    });
  }

  // Abre o menu de opções para registrar uma atividade.
  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Nova atividade',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.gps_fixed, color: Colors.deepOrange),
                title: const Text('Gravar com GPS'),
                subtitle:
                    const Text('Acompanhe o trajeto no mapa em tempo real'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TrackingPage()),
                  );
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.edit_note, color: Colors.deepOrange),
                title: const Text('Registro manual'),
                subtitle: const Text('Informe distância e tempo manualmente'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddActivityPage()),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      // FloatingActionButton central: oferece gravar por GPS ou registro manual
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
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
