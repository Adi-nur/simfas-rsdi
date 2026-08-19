import 'package:flutter/material.dart';

import 'item_list_page.dart';
import 'supplier_list_page.dart';
import 'user_management_page.dart';
import '../services/auth_service.dart';
import '../models/user_role.dart';

class MasterDataPage extends StatelessWidget {
  const MasterDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();

    final UserRole? currentRole = auth.currentRole;

    // ==========================================================
    // VALIDASI AKSES
    // ==========================================================

    if (!auth.canAccessMasterData()) {
      return _buildAccessDenied(context);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: Column(
        children: [
          _buildHeader(currentRole),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isWideScreen =
                    constraints.maxWidth >= 700;

                final int crossAxisCount =
                isWideScreen ? 4 : 2;

                return GridView.count(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    100,
                  ),

                  crossAxisCount: crossAxisCount,

                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,

                  childAspectRatio:
                  isWideScreen ? 1.15 : 1.05,

                  children: [
                    // ==================================================
                    // DATA BARANG
                    // ==================================================

                    _buildModernMenuCard(
                      context,
                      title: 'Data Barang',
                      subtitle:
                      'Kelola stok obat & alkes',
                      icon: Icons.inventory_2_rounded,
                      color: Colors.blue,
                      onTap: () {
                        _openPage(
                          context,
                          const ItemListPage(),
                        );
                      },
                    ),

                    // ==================================================
                    // DATA SUPPLIER
                    // ==================================================

                    _buildModernMenuCard(
                      context,
                      title: 'Data Supplier',
                      subtitle:
                      'Daftar vendor & rekanan',
                      icon: Icons.business_rounded,
                      color: Colors.teal,
                      onTap: () {
                        _openPage(
                          context,
                          const SupplierListPage(),
                        );
                      },
                    ),

                    // ==================================================
                    // MANAJEMEN USER
                    // ==================================================

                    if (currentRole ==
                        UserRole.superAdmin)
                      _buildModernMenuCard(
                        context,
                        title: 'Manajemen User',
                        subtitle:
                        'Kelola akses staf & poli',
                        icon:
                        Icons.people_alt_rounded,
                        color: Colors.indigo,
                        onTap: () {
                          _openPage(
                            context,
                            const UserManagementPage(),
                          );
                        },
                      ),

                    // ==================================================
                    // KATEGORI
                    // ==================================================

                    _buildModernMenuCard(
                      context,
                      title: 'Kategori',
                      subtitle:
                      'Pengelompokan jenis barang',
                      icon: Icons.category_rounded,
                      color: Colors.purple,
                      onTap: () {
                        _showComingSoon(
                          context,
                          'Kategori',
                        );
                      },
                    ),

                    // ==================================================
                    // SATUAN
                    // ==================================================

                    _buildModernMenuCard(
                      context,
                      title: 'Satuan',
                      subtitle:
                      'Strip, Box, Pcs, dll',
                      icon: Icons.straighten_rounded,
                      color: Colors.red,
                      onTap: () {
                        _showComingSoon(
                          context,
                          'Satuan',
                        );
                      },
                    ),

                    // ==================================================
                    // LOKASI GUDANG
                    // ==================================================

                    _buildModernMenuCard(
                      context,
                      title: 'Lokasi Gudang',
                      subtitle:
                      'Manajemen rak & gedung',
                      icon:
                      Icons.warehouse_rounded,
                      color: Colors.orange,
                      onTap: () {
                        _showComingSoon(
                          context,
                          'Lokasi Gudang',
                        );
                      },
                    ),

                    // ==================================================
                    // DEPARTEMEN
                    // ==================================================

                    _buildModernMenuCard(
                      context,
                      title: 'Departemen',
                      subtitle:
                      'Poli, IGD, ICU, dll',
                      icon:
                      Icons.meeting_room_rounded,
                      color: Colors.cyan,
                      onTap: () {
                        _showComingSoon(
                          context,
                          'Departemen',
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader(UserRole? currentRole) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        24,
        28,
        24,
        28,
      ),

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0D47A1),
            Color(0xFF1976D2),
          ],

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          const Text(
            'Master Data',

            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Pusat manajemen informasi logistik',

            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          // Role user yang sedang login
          if (currentRole != null)
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),

              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.15,
                ),

                borderRadius:
                BorderRadius.circular(20),
              ),

              child: Text(
                'Role: ${_roleLabel(currentRole)}',

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // MENU CARD
  // ==========================================================

  Widget _buildModernMenuCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius:
        BorderRadius.circular(24),

        child: Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
            BorderRadius.circular(24),

            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.04,
                ),

                blurRadius: 10,

                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [
              // Icon
              Container(
                padding:
                const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.1,
                  ),

                  shape: BoxShape.circle,
                ),

                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                title,

                textAlign: TextAlign.center,

                maxLines: 2,

                overflow:
                TextOverflow.ellipsis,

                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 5),

              // Subtitle
              Text(
                subtitle,

                textAlign: TextAlign.center,

                maxLines: 2,

                overflow:
                TextOverflow.ellipsis,

                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // NAVIGATE TO PAGE
  // ==========================================================

  void _openPage(
      BuildContext context,
      Widget page,
      ) {
    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  // ==========================================================
  // COMING SOON
  // ==========================================================

  void _showComingSoon(
      BuildContext context,
      String feature,
      ) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fitur $feature sedang dalam pengembangan.',
        ),

        behavior:
        SnackBarBehavior.floating,

        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ==========================================================
  // ACCESS DENIED
  // ==========================================================

  Widget _buildAccessDenied(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text('Master Data'),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [
              Container(
                padding:
                const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.red.withValues(
                    alpha: 0.1,
                  ),

                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Akses Ditolak',

                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Anda tidak memiliki hak akses '
                    'untuk membuka Master Data.',

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },

                icon: const Icon(
                  Icons.arrow_back,
                ),

                label: const Text(
                  'Kembali',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // ROLE LABEL
  // ==========================================================

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Super Admin';

      case UserRole.kepalaGudang:
        return 'Kepala Gudang';

      case UserRole.petugasGudang:
        return 'Petugas Gudang';

      case UserRole.unitPoli:
        return 'Unit / Poli';

      case UserRole.direktur:
        return 'Direktur';
    }
  }
}