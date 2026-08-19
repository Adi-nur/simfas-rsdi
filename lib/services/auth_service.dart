import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_role.dart';

class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Jangan gunakan role akses sebagai fallback yang sebenarnya.
  // Role akan ditentukan dari database setelah user login.
  UserRole? _currentRole;

  // ================================
  // GETTER
  // ================================

  UserRole? get currentRole => _currentRole;

  Session? get currentSession => _supabase.auth.currentSession;

  User? get currentUser => _supabase.auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  // ================================
  // INITIALIZE
  // ================================

  Future<void> initialize() async {
    try {
      final session = _supabase.auth.currentSession;

      if (session == null) {
        _currentRole = null;
        return;
      }

      await _fetchUserProfile(session.user.id);
    } catch (e) {
      _currentRole = null;
      throw Exception('Gagal menginisialisasi autentikasi: $e');
    }
  }

  // ================================
  // LOGIN
  // ================================

  Future<void> signIn(
      String email,
      String password, {
        UserRole? preferredRole,
      }) async {
    try {
      // Reset role sebelum login baru
      _currentRole = null;

      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw Exception('Data user tidak ditemukan.');
      }

      /*
       * PENTING:
       *
       * Role utama diambil dari database.
       * preferredRole hanya digunakan jika profile
       * memang belum tersedia.
       */
      final profile = await _getUserProfile(user.id);

      if (profile == null) {
        // Jika profile tidak ada, gunakan preferredRole atau default ke unitPoli
        final roleToUse = preferredRole ?? UserRole.unitPoli;

        await _createProfile(
          userId: user.id,
          fullName: user.userMetadata?['full_name'] ??
              user.email?.split('@').first ??
              'User Staf',
          role: roleToUse,
        );

        _currentRole = roleToUse;
      } else {
        final roleValue = profile['role'];

        if (roleValue == null) {
          throw Exception(
            'Role user belum diatur di database.',
          );
        }

        _currentRole = _mapStringToRole(
          roleValue.toString(),
        );
      }
    } on AuthException catch (e) {
      _currentRole = null;

      throw Exception(
        'Login gagal: ${e.message}',
      );
    } catch (e) {
      _currentRole = null;

      throw Exception(
        'Login gagal: $e',
      );
    }
  }

  // ================================
  // GET PROFILE
  // ================================

  Future<Map<String, dynamic>?> _getUserProfile(
      String userId,
      ) async {
    final data = await _supabase
        .from('profiles')
        .select('id, full_name, role')
        .eq('id', userId)
        .maybeSingle();

    return data;
  }

  // ================================
  // FETCH USER PROFILE
  // ================================

  Future<void> _fetchUserProfile(
      String userId,
      ) async {
    try {
      final data = await _getUserProfile(userId);

      if (data == null) {
        _currentRole = null;
        return;
      }

      final roleValue = data['role'];

      if (roleValue == null) {
        _currentRole = null;
        return;
      }

      _currentRole = _mapStringToRole(
        roleValue.toString(),
      );
    } catch (e) {
      _currentRole = null;

      throw Exception(
        'Gagal mengambil profil user: $e',
      );
    }
  }

  // ================================
  // CREATE PROFILE
  // ================================

  Future<void> _createProfile({
    required String userId,
    required String fullName,
    required UserRole role,
  }) async {
    await _supabase.from('profiles').insert({
      'id': userId,
      'full_name': fullName,
      'role': _roleToString(role),
    });
  }

  // ================================
  // REGISTER USER
  // ================================

  Future<void> registerNewUser({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName.trim(),
        },
      );

      final user = response.user;

      if (user == null) {
        throw Exception(
          'User gagal dibuat.',
        );
      }

      /*
       * Jika Supabase menggunakan email confirmation,
       * user bisa belum memiliki session.
       * Tetapi ID user tetap bisa digunakan untuk
       * membuat profile jika RLS mengizinkannya.
       */
      await _createProfile(
        userId: user.id,
        fullName: fullName.trim(),
        role: role,
      );
    } on AuthException catch (e) {
      throw Exception(
        'Registrasi gagal: ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'Registrasi gagal: $e',
      );
    }
  }

  // ================================
  // ROLE → STRING
  // ================================

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

  // ================================
  // STRING → ROLE
  // ================================

  UserRole _mapStringToRole(String role) {
    switch (role.toLowerCase().trim()) {
      case 'super_admin':
        return UserRole.superAdmin;

      case 'kepala_gudang':
        return UserRole.kepalaGudang;

      case 'petugas_gudang':
        return UserRole.petugasGudang;

      case 'unit_poli':
        return UserRole.unitPoli;

      case 'direktur':
        return UserRole.direktur;

      default:
        throw Exception(
          'Role "$role" tidak dikenali.',
        );
    }
  }

  // ================================
  // SET ROLE
  // ================================

  void setRole(UserRole role) {
    _currentRole = role;
  }

  // ================================
  // LOGOUT
  // ================================

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } finally {
      // Jangan sampai role user sebelumnya
      // terbawa ke login berikutnya.
      _currentRole = null;
    }
  }

  // ================================
  // PERMISSIONS
  // ================================

  bool showFinancialStats() {
    return _currentRole == UserRole.superAdmin ||
        _currentRole == UserRole.direktur;
  }

  bool showInventoryStats() {
    return _currentRole != null &&
        _currentRole != UserRole.unitPoli;
  }

  bool showOperationalTasks() {
    return _currentRole == UserRole.petugasGudang ||
        _currentRole == UserRole.superAdmin;
  }

  bool canAccessMasterData() {
    return _currentRole == UserRole.superAdmin ||
        _currentRole == UserRole.kepalaGudang;
  }

  bool canManageStock() {
    return _currentRole != null &&
        _currentRole != UserRole.direktur &&
        _currentRole != UserRole.unitPoli;
  }

  bool canViewAnalytics() {
    return _currentRole == UserRole.superAdmin ||
        _currentRole == UserRole.direktur ||
        _currentRole == UserRole.kepalaGudang;
  }

  bool canApproveRequests() {
    return _currentRole == UserRole.superAdmin ||
        _currentRole == UserRole.kepalaGudang;
  }

  bool canPerformStockOpname() {
    return _currentRole == UserRole.petugasGudang ||
        _currentRole == UserRole.superAdmin;
  }
}