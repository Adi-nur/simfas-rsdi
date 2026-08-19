import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_role.dart';
import '../services/auth_service.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() =>
      _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  final AuthService _authService = AuthService();

  bool _isLoading = true;

  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();

    _fetchUsers();
  }

  // ==========================================================
  // FETCH USERS
  // ==========================================================

  Future<void> _fetchUsers() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _supabase
          .from('profiles')
          .select('id, full_name, role')
          .order('full_name');

      if (!mounted) return;

      setState(() {
        _users = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showSnackBar(
        'Gagal memuat user: ${e.message}',
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showSnackBar(
        'Gagal memuat user: $e',
        isError: true,
      );
    }
  }

  // ==========================================================
  // SNACKBAR
  // ==========================================================

  void _showSnackBar(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ==========================================================
  // ROLE LABEL
  // ==========================================================

  String _roleLabel(String? role) {
    switch (role) {
      case 'super_admin':
        return 'Super Admin';

      case 'kepala_gudang':
        return 'Kepala Gudang';

      case 'petugas_gudang':
        return 'Petugas Gudang';

      case 'unit_poli':
        return 'Unit / Poli';

      case 'direktur':
        return 'Direktur';

      default:
        return 'Role Tidak Diketahui';
    }
  }

  // ==========================================================
  // ROLE ICON
  // ==========================================================

  IconData _roleIcon(String? role) {
    switch (role) {
      case 'super_admin':
        return Icons.admin_panel_settings;

      case 'kepala_gudang':
        return Icons.warehouse;

      case 'petugas_gudang':
        return Icons.inventory_2;

      case 'unit_poli':
        return Icons.local_hospital;

      case 'direktur':
        return Icons.business_center;

      default:
        return Icons.person_outline;
    }
  }

  // ==========================================================
  // ROLE COLOR
  // ==========================================================

  Color _roleColor(String? role) {
    switch (role) {
      case 'super_admin':
        return const Color(0xFF0D47A1);

      case 'kepala_gudang':
        return const Color(0xFF7B1FA2);

      case 'petugas_gudang':
        return const Color(0xFF00838F);

      case 'unit_poli':
        return const Color(0xFF2E7D32);

      case 'direktur':
        return const Color(0xFFE65100);

      default:
        return Colors.grey;
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    // Hanya Super Admin yang boleh mengakses halaman ini.
    if (_authService.currentRole != UserRole.superAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),

        appBar: AppBar(
          title: const Text('Manajemen User'),
        ),

        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: Colors.red,
                ),

                SizedBox(height: 16),

                Text(
                  'Akses Ditolak',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Halaman ini hanya dapat diakses oleh Super Admin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text('Manajemen User'),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading
                ? null
                : _fetchUsers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: _buildBody(),

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: _showAddUserDialog,

        backgroundColor:
        const Color(0xFF0D47A1),

        foregroundColor: Colors.white,

        icon: const Icon(Icons.person_add),

        label: const Text('Tambah User'),
      ),
    );
  }

  // ==========================================================
  // BODY
  // ==========================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_users.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchUsers,

        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),

          children: const [
            SizedBox(height: 180),

            Icon(
              Icons.people_outline,
              size: 70,
              color: Colors.grey,
            ),

            SizedBox(height: 16),

            Center(
              child: Text(
                'Belum ada data user.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchUsers,

      child: ListView.builder(
        physics:
        const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          100,
        ),

        itemCount: _users.length,

        itemBuilder: (context, index) {
          final user = _users[index];

          return _buildUserCard(user);
        },
      ),
    );
  }

  // ==========================================================
  // USER CARD
  // ==========================================================

  Widget _buildUserCard(
      Map<String, dynamic> user,
      ) {
    final String name =
    (user['full_name'] ?? 'Tanpa Nama')
        .toString();

    final String role =
    (user['role'] ?? '').toString();

    final Color roleColor = _roleColor(role);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),

        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),

      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        leading: CircleAvatar(
          radius: 25,

          backgroundColor:
          roleColor.withValues(alpha: 0.1),

          child: Icon(
            _roleIcon(role),
            color: roleColor,
          ),
        ),

        title: Text(
          name,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),

        subtitle: Padding(
          padding:
          const EdgeInsets.only(top: 6),

          child: Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),

            decoration: BoxDecoration(
              color:
              roleColor.withValues(alpha: 0.1),

              borderRadius:
              BorderRadius.circular(20),
            ),

            child: Text(
              _roleLabel(role),

              style: TextStyle(
                color: roleColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }

  // ==========================================================
  // ADD USER DIALOG
  // ==========================================================

  void _showAddUserDialog() {
    final nameController =
    TextEditingController();

    final emailController =
    TextEditingController();

    final passwordController =
    TextEditingController();

    UserRole selectedRole =
        UserRole.unitPoli;

    bool isSaving = false;

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.white,

      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
              context,
              setModalState,
              ) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom:
                  MediaQuery.of(context)
                      .viewInsets
                      .bottom +
                      24,
                ),

                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                    MainAxisSize.min,

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      // ========================================
                      // HEADER
                      // ========================================

                      Row(
                        children: [
                          Container(
                            padding:
                            const EdgeInsets.all(
                              10,
                            ),

                            decoration:
                            BoxDecoration(
                              color: const Color(
                                0xFF0D47A1,
                              ).withValues(
                                alpha: 0.1,
                              ),

                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                            ),

                            child: const Icon(
                              Icons.person_add,
                              color:
                              Color(0xFF0D47A1),
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Expanded(
                            child: Text(
                              'Registrasi Staf Baru',

                              style: TextStyle(
                                fontSize: 20,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              Navigator.pop(
                                sheetContext,
                              );
                            },

                            icon: const Icon(
                              Icons.close,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ========================================
                      // NAMA
                      // ========================================

                      const Text(
                        'Nama Lengkap',

                        style: TextStyle(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller:
                        nameController,

                        textCapitalization:
                        TextCapitalization.words,

                        decoration:
                        InputDecoration(
                          hintText:
                          'Masukkan nama lengkap',

                          prefixIcon:
                          const Icon(
                            Icons.person_outline,
                          ),

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ========================================
                      // EMAIL
                      // ========================================

                      const Text(
                        'Email',

                        style: TextStyle(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller:
                        emailController,

                        keyboardType:
                        TextInputType
                            .emailAddress,

                        autocorrect: false,

                        decoration:
                        InputDecoration(
                          hintText:
                          'Masukkan email staf',

                          prefixIcon:
                          const Icon(
                            Icons.email_outlined,
                          ),

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ========================================
                      // PASSWORD
                      // ========================================

                      const Text(
                        'Password',

                        style: TextStyle(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller:
                        passwordController,

                        obscureText: true,

                        decoration:
                        InputDecoration(
                          hintText:
                          'Minimal 6 karakter',

                          prefixIcon:
                          const Icon(
                            Icons.lock_outline,
                          ),

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ========================================
                      // ROLE
                      // ========================================

                      const Text(
                        'Role Akses',

                        style: TextStyle(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      DropdownButtonFormField<UserRole>(
                        initialValue:
                        selectedRole,

                        decoration:
                        InputDecoration(
                          prefixIcon:
                          const Icon(
                            Icons
                                .admin_panel_settings_outlined,
                          ),

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),

                        items: UserRole.values
                            .map(
                              (role) {
                            return DropdownMenuItem<
                                UserRole>(
                              value: role,

                              child: Text(
                                _roleLabel(
                                  _roleToString(
                                    role,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                            .toList(),

                        onChanged: isSaving
                            ? null
                            : (value) {
                          if (value ==
                              null) {
                            return;
                          }

                          setModalState(() {
                            selectedRole =
                                value;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // ========================================
                      // BUTTON
                      // ========================================

                      SizedBox(
                        width: double.infinity,
                        height: 52,

                        child:
                        ElevatedButton(
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(
                              0xFF0D47A1,
                            ),

                            foregroundColor:
                            Colors.white,

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),

                          onPressed: isSaving
                              ? null
                              : () async {
                            // ==========================
                            // VALIDATION
                            // ==========================

                            final name =
                            nameController
                                .text
                                .trim();

                            final email =
                            emailController
                                .text
                                .trim();

                            final password =
                                passwordController
                                    .text;

                            if (name.isEmpty) {
                              _showDialogError(
                                'Nama lengkap wajib diisi.',
                              );
                              return;
                            }

                            if (email.isEmpty ||
                                !email.contains(
                                  '@',
                                )) {
                              _showDialogError(
                                'Masukkan email yang valid.',
                              );
                              return;
                            }

                            if (password
                                .length <
                                6) {
                              _showDialogError(
                                'Password minimal 6 karakter.',
                              );
                              return;
                            }

                            setModalState(() {
                              isSaving =
                              true;
                            });

                            try {
                              await _authService
                                  .registerNewUser(
                                email: email,
                                password:
                                password,
                                fullName:
                                name,
                                role:
                                selectedRole,
                              );

                              if (!mounted) {
                                return;
                              }

                              Navigator.pop(
                                sheetContext,
                              );

                              await _fetchUsers();

                              _showSnackBar(
                                'User berhasil didaftarkan.',
                              );
                            } catch (e) {
                              if (!context
                                  .mounted) {
                                return;
                              }

                              setModalState(() {
                                isSaving =
                                false;
                              });

                              String message =
                              e.toString();

                              if (message
                                  .startsWith(
                                'Exception: ',
                              )) {
                                message =
                                    message.substring(
                                      11,
                                    );
                              }

                              _showDialogError(
                                message,
                              );
                            }
                          },

                          child: isSaving
                              ? const SizedBox(
                            width: 24,
                            height: 24,

                            child:
                            CircularProgressIndicator(
                              strokeWidth:
                              2.5,

                              color:
                              Colors.white,
                            ),
                          )
                              : const Text(
                            'DAFTARKAN USER',

                            style:
                            TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      emailController.dispose();
      passwordController.dispose();
    });
  }

  // ==========================================================
  // DIALOG ERROR
  // ==========================================================

  void _showDialogError(String message) {
    if (!mounted) return;

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Data Tidak Valid',
          ),

          content: Text(message),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // ROLE → STRING
  // ==========================================================

  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'super_admin';

      case UserRole.kepalaGudang:
        return 'kepala_gudang';

      case UserRole.petugasGudang:
        return 'petugas_gudang';

      case UserRole.unitPoli:
        return 'unit_poli';

      case UserRole.direktur:
        return 'direktur';
    }
  }
}