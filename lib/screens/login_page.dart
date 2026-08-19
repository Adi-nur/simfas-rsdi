import 'package:flutter/material.dart';

import '../models/user_role.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final AuthService _authService = AuthService();

  UserRole _selectedRole = UserRole.superAdmin;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================
  // HANDLE LOGIN
  // ==========================================

  Future<void> _handleLogin() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      /*
       * Role TIDAK dikirim dari halaman login.
       *
       * AuthService akan mengambil role dari:
       *
       * profiles.role
       *
       * berdasarkan user.id.
       */
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        preferredRole: _selectedRole,
      );

      if (!mounted) return;

      // Pastikan role berhasil ditemukan
      if (_authService.currentRole == null) {
        throw Exception(
          'Role akun belum ditemukan. '
              'Silakan hubungi administrator.',
        );
      }

      // Login berhasil
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      String message = e.toString();

      // Menghilangkan "Exception:" agar pesan lebih bersih
      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: Stack(
        children: [
          // ==========================================
          // BACKGROUND HEADER
          // ==========================================

          Container(
            height: MediaQuery.of(context).size.height * 0.4,

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
                bottom: Radius.circular(40),
              ),
            ),
          ),

          // ==========================================
          // CONTENT
          // ==========================================

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // ==========================================
                  // LOGO
                  // ==========================================

                  Container(
                    padding: const EdgeInsets.all(4),

                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),

                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo_vektor.jpg',

                        width: 100,
                        height: 100,

                        fit: BoxFit.cover,

                        errorBuilder: (
                            context,
                            error,
                            stackTrace,
                            ) {
                          return const SizedBox(
                            width: 100,
                            height: 100,

                            child: Icon(
                              Icons.local_hospital,
                              size: 50,
                              color: Color(0xFF0D47A1),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==========================================
                  // TITLE
                  // ==========================================

                  const Text(
                    'SIMFAS RSDI KENDAL',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Sistem Manajemen Fasilitas',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Rumah Sakit Umum Muhammadiyah Darul Istiqomah',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ==========================================
                  // LOGIN CARD
                  // ==========================================

                  Container(
                    padding: const EdgeInsets.all(24),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(30),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.1,
                          ),

                          blurRadius: 20,

                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Form(
                      key: _formKey,

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [
                          // ==========================================
                          // WELCOME
                          // ==========================================

                          const Text(
                            'Selamat Datang',

                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            'Silakan masuk untuk melanjutkan',

                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // ==========================================
                          // ROLE SELECTOR
                          // ==========================================

                          const Text(
                            'Role Akses',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),

                          const SizedBox(height: 8),

                          DropdownButtonFormField<UserRole>(
                            initialValue: _selectedRole,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                            ),
                            items: UserRole.values.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(
                                  _roleLabel(role),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedRole = v!),
                          ),

                          const SizedBox(height: 20),

                          // ==========================================
                          // EMAIL
                          // ==========================================

                          const Text(
                            'Email',

                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _emailController,

                            keyboardType:
                            TextInputType.emailAddress,

                            textInputAction:
                            TextInputAction.next,

                            autocorrect: false,

                            decoration: InputDecoration(
                              hintText: 'Masukkan email',

                              prefixIcon: const Icon(
                                Icons.email_outlined,
                              ),

                              filled: true,

                              fillColor:
                              const Color(0xFFF8FAFC),

                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(12),

                                borderSide: BorderSide.none,
                              ),

                              enabledBorder:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(12),

                                borderSide:
                                const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),

                              focusedBorder:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(12),

                                borderSide:
                                const BorderSide(
                                  color: Color(0xFF0D47A1),
                                  width: 2,
                                ),
                              ),
                            ),

                            validator: (value) {
                              final email =
                                  value?.trim() ?? '';

                              if (email.isEmpty) {
                                return 'Email tidak boleh kosong';
                              }

                              if (!email.contains('@')) {
                                return 'Format email tidak valid';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // ==========================================
                          // PASSWORD
                          // ==========================================

                          const Text(
                            'Password',

                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _passwordController,

                            obscureText: _obscurePassword,

                            textInputAction:
                            TextInputAction.done,

                            onFieldSubmitted: (_) {
                              if (!_isLoading) {
                                _handleLogin();
                              }
                            },

                            decoration: InputDecoration(
                              hintText: 'Masukkan password',

                              prefixIcon: const Icon(
                                Icons.lock_outline,
                              ),

                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Tampilkan password'
                                    : 'Sembunyikan password',

                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons
                                      .visibility_off_outlined,
                                ),

                                onPressed: () {
                                  setState(() {
                                    _obscurePassword =
                                    !_obscurePassword;
                                  });
                                },
                              ),

                              filled: true,

                              fillColor:
                              const Color(0xFFF8FAFC),

                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(12),

                                borderSide: BorderSide.none,
                              ),

                              enabledBorder:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(12),

                                borderSide:
                                const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),

                              focusedBorder:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(12),

                                borderSide:
                                const BorderSide(
                                  color: Color(0xFF0D47A1),
                                  width: 2,
                                ),
                              ),
                            ),

                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 32),

                          // ==========================================
                          // LOGIN BUTTON
                          // ==========================================

                          SizedBox(
                            width: double.infinity,
                            height: 56,

                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFF0D47A1),

                                foregroundColor: Colors.white,

                                disabledBackgroundColor:
                                const Color(0xFF94A3B8),

                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),

                                elevation: 0,
                              ),

                              onPressed: _isLoading
                                  ? null
                                  : _handleLogin,

                              child: _isLoading
                                  ? const SizedBox(
                                width: 24,
                                height: 24,

                                child:
                                CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(
                                'LOGIN SYSTEM',

                                style: TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    '© 2026 RSDI KENDAL - Versi 1.0.0 Pro',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
