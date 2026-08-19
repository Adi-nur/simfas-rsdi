import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/dashboard_page.dart';
import 'screens/master_data_page.dart';
import 'screens/stock_management_page.dart';
import 'screens/login_page.dart';
import 'screens/transaction_history_page.dart';
import 'models/user_role.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://jrzfamowqpcjlzkrdsah.supabase.co',
    publishableKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpyemZhbW93cXBjamx6a3Jkc2FoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYzOTY2NDksImV4cCI6MjEwMTk3MjY0OX0.RLbEEgxXoPOe3vysF5xC27_Q1jfMmnq3uuI5ajvE3rY',
  );

  // Inisialisasi AuthService
  await AuthService().initialize();

  runApp(const SIMFASApp());
}

class SIMFASApp extends StatelessWidget {
  const SIMFASApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMFAS RSDI KENDAL',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          primary: const Color(0xFF0D47A1),
          secondary: const Color(0xFF1976D2),
        ),
        useMaterial3: true,

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MainNavigation(),
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final AuthService _auth = AuthService();

  late List<_NavigationItem> _navigationItems;

  @override
  void initState() {
    super.initState();
    _buildNavigationItems();
  }

  /// Membuat menu dan halaman berdasarkan role user.
  void _buildNavigationItems() {
    _navigationItems = [
      _NavigationItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
        label: 'Beranda',
        page: const DashboardPage(),
      ),
    ];

    // Master Data
    if (_auth.canAccessMasterData()) {
      _navigationItems.add(
        _NavigationItem(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2_rounded,
          label: 'Master',
          page: const MasterDataPage(),
        ),
      );
    }

    // Manajemen Stok
    if (_auth.canManageStock()) {
      _navigationItems.add(
        _NavigationItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long_rounded,
          label: 'Stok',
          page: const StockManagementPage(),
        ),
      );
    }

    // Laporan
    if (_auth.canViewAnalytics()) {
      _navigationItems.add(
        _NavigationItem(
          icon: Icons.analytics_outlined,
          activeIcon: Icons.analytics_rounded,
          label: 'Laporan',
          page: const TransactionHistoryPage(
            title: 'Laporan & Analitik',
          ),
        ),
      );
    }

    // Menu khusus Unit/Poli
    //
    // Aktifkan bagian ini jika Anda sudah memiliki halaman
    // untuk permintaan barang.
    //
    // if (_auth.currentRole == UserRole.unitPoli) {
    //   _navigationItems.add(
    //     _NavigationItem(
    //       icon: Icons.assignment_outlined,
    //       activeIcon: Icons.assignment_rounded,
    //       label: 'Permintaan',
    //       page: const RequestPage(),
    //     ),
    //   );
    // }
  }

  void _onItemTapped(int index) {
    if (index < 0 || index >= _navigationItems.length) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan index tetap valid.
    if (_selectedIndex >= _navigationItems.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      drawer: _buildProfessionalDrawer(context),

      body: SafeArea(
        child: _navigationItems[_selectedIndex].page,
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),

        child: BottomNavigationBar(
          currentIndex: _selectedIndex,

          items: [
            for (final item in _navigationItems)
              BottomNavigationBarItem(
                icon: Icon(item.icon),
                activeIcon: Icon(item.activeIcon),
                label: item.label,
              ),

            const BottomNavigationBarItem(
              icon: Icon(
                Icons.logout_rounded,
                color: Colors.red,
              ),
              label: 'Keluar',
            ),
          ],

          selectedItemColor: const Color(0xFF0D47A1),
          unselectedItemColor: const Color(0xFF94A3B8),

          onTap: (index) {
            // Index terakhir adalah Logout.
            if (index == _navigationItems.length) {
              _showLogoutConfirmation(context);
              return;
            }

            _onItemTapped(index);
          },

          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,

          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),

          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// Dialog konfirmasi logout.
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar Akun'),

          content: const Text(
            'Apakah Anda yakin ingin keluar dari akun?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),

              onPressed: () async {
                try {
                  // Logout dari Supabase
                  await Supabase.instance.client.auth.signOut();

                  if (!context.mounted) return;

                  // Kembali ke halaman login dan hapus
                  // halaman sebelumnya dari stack.
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                        (route) => false,
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Gagal keluar dari akun: $e',
                      ),
                    ),
                  );
                }
              },

              child: const Text('Ya, Keluar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfessionalDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,

      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1976D2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),

            currentAccountPicture: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),

              child: ClipOval(
                child: Image.asset(
                  'assets/logo_vektor.jpg',
                  fit: BoxFit.cover,

                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.local_hospital,
                      color: Color(0xFF0D47A1),
                      size: 40,
                    );
                  },
                ),
              ),
            ),

            accountName: const Text(
              'SIMFAS RSDI KENDAL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            accountEmail: const Text(
              'Rumah Sakit Umum Muhammadiyah Darul Istiqomah',
              style: TextStyle(
                fontSize: 11,
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,

              children: [
                for (int i = 0; i < _navigationItems.length; i++)
                  _buildDrawerItem(
                    i,
                    _navigationItems[i].icon,
                    _navigationItems[i].label,
                  ),

                const Divider(
                  indent: 20,
                  endIndent: 20,
                ),

                ListTile(
                  leading: const Icon(
                    Icons.settings_outlined,
                    color: Color(0xFF64748B),
                  ),

                  title: const Text(
                    'Pengaturan Sistem',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.help_outline_rounded,
                    color: Color(0xFF64748B),
                  ),

                  title: const Text(
                    'Pusat Bantuan',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),

            child: ListTile(
              tileColor: Colors.red.withValues(alpha: 0.05),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
              ),

              title: const Text(
                'Keluar Akun',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

              onTap: () {
                Navigator.pop(context);

                _showLogoutConfirmation(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      int index,
      IconData icon,
      String title,
      ) {
    final bool isSelected = _selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? const Color(0xFF0D47A1)
            : const Color(0xFF64748B),
      ),

      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? const Color(0xFF0D47A1)
              : const Color(0xFF1E293B),
          fontWeight: isSelected
              ? FontWeight.w700
              : FontWeight.w500,
        ),
      ),

      selected: isSelected,

      selectedTileColor: const Color(
        0xFF0D47A1,
      ).withValues(alpha: 0.05),

      onTap: () {
        _onItemTapped(index);
        Navigator.pop(context);
      },
    );
  }
}

/// Model sederhana untuk menyimpan menu + halaman.
/// Dengan cara ini index menu dan halaman selalu sama.
class _NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget page;

  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.page,
  });
}