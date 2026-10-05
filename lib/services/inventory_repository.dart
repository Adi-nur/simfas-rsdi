import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../models/inventory_item.dart';

class InventoryRepository {
  final _supabase = Supabase.instance.client;

  // ==========================================
  // MASTER DATA: BARANG
  // ==========================================

  // Mendapatkan semua item barang
  Future<List<Map<String, dynamic>>> getAllItems() async {
    try {
      final response = await _supabase
          .from('items')
          .select('*')
          .order('name');
      return response;
    } catch (e) {
      throw Exception('Gagal memuat data barang: $e');
    }
  }

  // Tambah barang baru
  Future<void> addItem(Map<String, dynamic> itemData) async {
    try {
      await _supabase.from('items').insert(itemData);
    } catch (e) {
      throw Exception('Gagal menambah barang: $e');
    }
  }

  // Upload Foto ke Supabase Storage dengan error handling lebih baik
  Future<String?> uploadMaintenancePhoto(String path, List<int> bytes, String fileName) async {
    try {
      final String fullPath = 'maintenance/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      await _supabase.storage.from('inventory_assets').uploadBinary(
        fullPath,
        Uint8List.fromList(bytes),
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final String publicUrl = _supabase.storage.from('inventory_assets').getPublicUrl(fullPath);
      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Hapus barang
  Future<void> deleteItem(String itemId) async {
    try {
      await _supabase.from('items').delete().eq('id', itemId);
    } catch (e) {
      throw Exception('Gagal menghapus barang: $e');
    }
  }

  // Mencari barang berdasarkan Barcode (Integrasi dengan Scanner)
  Future<Map<String, dynamic>?> getItemByCode(String code) async {
    try {
      final response = await _supabase
          .from('items')
          .select()
          .eq('code', code)
          .maybeSingle();
      return response;
    } catch (e) {
      throw Exception('Gagal mencari barang: $e');
    }
  }

  // ==========================================
  // MASTER DATA: SUPPLIER
  // ==========================================

  // Ambil semua supplier
  Future<List<Map<String, dynamic>>> getSuppliers() async {
    try {
      final response = await _supabase
          .from('suppliers')
          .select('*')
          .order('name');
      return response;
    } catch (e) {
      throw Exception('Gagal memuat data supplier: $e');
    }
  }

  // Tambah supplier baru
  Future<void> addSupplier(Map<String, dynamic> supplierData) async {
    try {
      await _supabase.from('suppliers').insert(supplierData);
    } catch (e) {
      throw Exception('Gagal menambah supplier: $e');
    }
  }

  // Update data supplier
  Future<void> updateSupplier(String id, Map<String, dynamic> supplierData) async {
    try {
      await _supabase.from('suppliers').update(supplierData).eq('id', id);
    } catch (e) {
      throw Exception('Gagal memperbarui supplier: $e');
    }
  }

  // Hapus data supplier
  Future<void> deleteSupplier(String id) async {
    try {
      await _supabase.from('suppliers').delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus supplier: $e');
    }
  }

  // ==========================================
  // MASTER DATA: KATEGORI
  // ==========================================

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select('*')
          .order('name');
      
      if (response.isNotEmpty) {
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (_) {
      // Jika tabel belum ada di DB, kembalikan daftar default
    }

    return [
      {'id': '1', 'name': 'Obat', 'code': 'OBT', 'description': 'Obat-obatan medis & farmasi'},
      {'id': '2', 'name': 'Alat Medis', 'code': 'ALK', 'description': 'Peralatan medis & bedah'},
      {'id': '3', 'name': 'Bahan Habis Pakai (BHP)', 'code': 'BHP', 'description': 'Spuit, perban, kassa, infus'},
      {'id': '4', 'name': 'Alat Pelindung Diri (APD)', 'code': 'APD', 'description': 'Masker, hazmat, sarung tangan'},
      {'id': '5', 'name': 'Laboratorium', 'code': 'LAB', 'description': 'Reagen & bahan uji laboratorium'},
      {'id': '6', 'name': 'Radiologi', 'code': 'RAD', 'description': 'Film X-ray & bahan radiologi'},
      {'id': '7', 'name': 'ATK & Cetakan', 'code': 'ATK', 'description': 'Alat tulis kantor & formulir'},
      {'id': '8', 'name': 'Elektronik & IT', 'code': 'ELK', 'description': 'Komputer, printer & medis elektronik'},
      {'id': '9', 'name': 'Furniture & Mebel', 'code': 'FUR', 'description': 'Bed pasien, meja, kursi, lemari'},
    ];
  }

  Future<void> addCategory(Map<String, dynamic> categoryData) async {
    try {
      await _supabase.from('categories').insert(categoryData);
    } catch (e) {
      throw Exception('Gagal menambah kategori: $e');
    }
  }

  Future<void> updateCategory(String id, Map<String, dynamic> categoryData) async {
    try {
      await _supabase.from('categories').update(categoryData).eq('id', id);
    } catch (e) {
      throw Exception('Gagal memperbarui kategori: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _supabase.from('categories').delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus kategori: $e');
    }
  }

  // ==========================================
  // TRANSAKSI & STOK
  // ==========================================

  // Ambil riwayat transaksi stok
  Future<List<Map<String, dynamic>>> getStockTransactions({String? type}) async {
    try {
      var query = _supabase
          .from('stock_transactions')
          .select('*, items(name), profiles(full_name)');
      
      if (type != null) {
        query = query.eq('type', type);
      }
      
      final response = await query.order('created_at', ascending: false);
      return response;
    } catch (e) {
      throw Exception('Gagal memuat riwayat transaksi: $e');
    }
  }

  // Membuat transaksi stok (Masuk/Keluar/Mutasi)
  Future<void> createTransaction({
    required int itemId,
    required String type,
    required int quantity,
    required String description,
    int? fromWarehouse,
    int? toWarehouse,
  }) async {
    try {
      await _supabase.from('stock_transactions').insert({
        'item_id': itemId,
        'user_id': _supabase.auth.currentUser?.id,
        'type': type,
        'quantity': quantity,
        'from_warehouse_id': fromWarehouse,
        'to_warehouse_id': toWarehouse,
        'description': description,
      });
    } catch (e) {
      throw Exception('Gagal menyimpan transaksi: $e');
    }
  }

  // ==========================================
  // PERMINTAAN & APPROVAL
  // ==========================================

  // Mengajukan permintaan barang (Role Unit/Poli)
  Future<void> createRequest(List<Map<String, dynamic>> items, String notes) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      final request = await _supabase.from('requests').insert({
        'requester_id': userId,
        'notes': notes,
        'status': 'pending',
      }).select().single();

      final requestItems = items.map((item) => {
        'request_id': request['id'],
        'item_id': item['item_id'],
        'quantity_requested': item['quantity'],
      }).toList();

      await _supabase.from('request_items').insert(requestItems);
    } catch (e) {
      throw Exception('Gagal membuat permintaan: $e');
    }
  }

  // Mendapatkan daftar permintaan untuk approval
  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    try {
      final response = await _supabase
          .from('requests')
          .select('*, profiles(full_name), request_items(*, items(*))')
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      throw Exception('Gagal memuat daftar permintaan: $e');
    }
  }

  // Menyetujui permintaan
  Future<void> approveRequest(int requestId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      await _supabase.from('requests').update({
        'status': 'approved',
        'approved_by': userId,
      }).eq('id', requestId);
    } catch (e) {
      throw Exception('Gagal menyetujui permintaan: $e');
    }
  }

  // ==========================================
  // PURCHASE ORDERS
  // ==========================================

  // Ambil riwayat Purchase Order
  Future<List<Map<String, dynamic>>> getPurchaseOrders() async {
    try {
      final response = await _supabase
          .from('purchase_orders')
          .select('*, suppliers(name), profiles(full_name)')
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      throw Exception('Gagal memuat Purchase Order: $e');
    }
  }

  // ==========================================
  // DASHBOARD & ANALITIK
  // ==========================================

  Future<Map<String, dynamic>> getDashboardStats() async {
    int totalItems = 0;
    int lowStockCount = 0;
    double totalValue = 0;
    int pendingRequests = 0;
    int pendingMaintenance = 0;

    // 1. Ambil data barang (Items) dan gunakan InventoryItem parsing agar 100% konsisten dengan Daftar Inventaris
    try {
      final List<Map<String, dynamic>> itemsData = await getAllItems();
      totalItems = itemsData.length;

      for (var itemMap in itemsData) {
        final item = InventoryItem.fromMap(itemMap);
        if (item.stock < item.minStock) {
          lowStockCount++;
        }
        totalValue += (item.stock * item.price);
      }
    } catch (_) {}

    // 2. Ambil data pengajuan pending dari tabel 'requests'
    try {
      final List<dynamic> requests = await _supabase
          .from('requests')
          .select('id')
          .eq('status', 'pending');
      pendingRequests = requests.length;
    } catch (_) {}

    // 3. Ambil data laporan kerusakan/pemeliharaan pending dari tabel 'maintenance_logs'
    try {
      final List<dynamic> maintenanceLogs = await _supabase
          .from('maintenance_logs')
          .select('id')
          .eq('status', 'pending');
      pendingMaintenance = maintenanceLogs.length;
    } catch (_) {}

    // Jika RPC get_total_inventory_value ada dan totalValue masih 0, coba panggil RPC
    if (totalValue == 0) {
      try {
        final totalAsetResult = await _supabase.rpc('get_total_inventory_value');
        if (totalAsetResult != null) {
          totalValue = (totalAsetResult as num).toDouble();
        }
      } catch (_) {}
    }

    // Total pending gabungan (Permintaan Barang + Laporan Pemeliharaan/Kerusakan)
    int totalPending = pendingRequests + pendingMaintenance;

    return {
      'total_items': totalItems,
      'low_stock': lowStockCount,
      'pending_requests': totalPending,
      'pending_maintenance': pendingMaintenance,
      'total_value': totalValue,
    };
  }

  // Ambil data aktivitas terbaru secara real-time
  Future<List<Map<String, dynamic>>> getRecentActivities({String? userId, String? role}) async {
    List<Map<String, dynamic>> activities = [];

    // 1. Ambil transaksi stok terbaru
    try {
      var query = _supabase
          .from('stock_transactions')
          .select('*, items(name), profiles(full_name)');
      
      if (userId != null && role == 'unit_poli') {
        query = query.eq('user_id', userId);
      }
      
      final transactions = await query.order('created_at', ascending: false).limit(5);

      for (var tx in transactions) {
        final createdAt = DateTime.tryParse(tx['created_at']?.toString() ?? '') ?? DateTime.now();
        final itemName = tx['items']?['name'] ?? 'Barang';
        final qty = tx['quantity'] ?? 0;
        final userName = tx['profiles']?['full_name'] ?? 'Sistem';
        final type = tx['type']?.toString();

        String title = 'Transaksi Stok';
        String iconType = 'info';

        if (type == 'masuk') {
          title = 'Barang Masuk: $itemName ($qty Unit)';
          iconType = 'masuk';
        } else if (type == 'keluar') {
          title = 'Barang Keluar: $itemName ($qty Unit)';
          iconType = 'keluar';
        } else if (type == 'mutasi') {
          title = 'Mutasi Barang: $itemName ($qty Unit)';
          iconType = 'mutasi';
        }

        activities.add({
          'title': title,
          'subtitle': 'Oleh $userName',
          'created_at': createdAt,
          'type': iconType,
        });
      }
    } catch (_) {}

    // 2. Ambil laporan pemeliharaan/kerusakan terbaru
    try {
      var query = _supabase
          .from('maintenance_logs')
          .select('''
            *,
            items(name),
            reporter:profiles!maintenance_logs_reporter_id_fkey(full_name)
          ''');

      if (userId != null && role == 'unit_poli') {
        query = query.eq('reporter_id', userId);
      }

      final logs = await query.order('created_at', ascending: false).limit(5);

      for (var log in logs) {
        final createdAt = DateTime.tryParse(log['created_at']?.toString() ?? '') ?? DateTime.now();
        final itemName = log['items']?['name'] ?? 'Barang';
        final reporter = log['reporter']?['full_name'] ?? 'Pelapor';
        final status = log['status']?.toString() ?? 'pending';

        activities.add({
          'title': 'Lapor Kerusakan: $itemName',
          'subtitle': 'Oleh $reporter • Status: ${status.toUpperCase()}',
          'created_at': createdAt,
          'type': 'maintenance',
        });
      }
    } catch (_) {}

    // 3. Urutkan semua aktivitas berdasarkan waktu terbaru
    activities.sort((a, b) {
      final aDate = a['created_at'] as DateTime;
      final bDate = b['created_at'] as DateTime;
      return bDate.compareTo(aDate);
    });

    // Ambil maksimal 5 aktivitas teratas
    if (activities.length > 5) {
      return activities.sublist(0, 5);
    }

    return activities;
  }

  // Ambil profil staf untuk penugasan
  Future<List<Map<String, dynamic>>> getStaffProfiles() async {
    try {
      // Ambil semua profil terlebih dahulu untuk pengecekan
      final response = await _supabase
          .from('profiles')
          .select('id, full_name, role');
      
      // Filter di sisi aplikasi agar hanya menampilkan Petugas Gudang
      final staff = (response as List).where((u) {
        final role = u['role']?.toString().toLowerCase() ?? '';
        return role == 'petugas_gudang';
      }).toList();

      return staff.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Gagal memuat profil staf: $e');
    }
  }

  // ==========================================
  // PEMELIHARAAN & KERUSAKAN (ENHANCED)
  // ==========================================

  Future<List<Map<String, dynamic>>> getMaintenanceLogs() async {
    try {
      // Menggunakan join yang lebih sederhana jika FK alias bermasalah
      final response = await _supabase
          .from('maintenance_logs')
          .select('''
            *,
            items(name),
            reporter:profiles!maintenance_logs_reporter_id_fkey(full_name),
            assignee:profiles!maintenance_logs_assigned_to_fkey(full_name)
          ''')
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      throw Exception('Gagal memuat data pemeliharaan: $e');
    }
  }

  Future<void> createMaintenanceReport({
    required int itemId,
    required String description,
    required String damageLevel,
    String? location,
    String? photoUrl,
  }) async {
    try {
      await _supabase.from('maintenance_logs').insert({
        'item_id': itemId,
        'reporter_id': _supabase.auth.currentUser?.id,
        'description': description,
        'damage_level': damageLevel,
        'status': 'pending',
        'location': location,
        'photo_url': photoUrl,
      });
    } catch (e) {
      throw Exception('Gagal membuat laporan kerusakan: $e');
    }
  }

  Future<void> assignMaintenance(String id, String petugasId, DateTime estimatedFinish) async {
    try {
      await _supabase.from('maintenance_logs').update({
        'assigned_to': petugasId,
        'status': 'perbaikan',
        'estimated_finish': estimatedFinish.toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw Exception('Gagal menugaskan petugas: $e');
    }
  }

  Future<void> updateMaintenanceStatus(String id, String status, {double? cost, Map<String, dynamic>? auditEntry}) async {
    try {
      final Map<String, dynamic> updateData = {'status': status};
      
      if (status == 'selesai') {
        updateData['fixed_at'] = DateTime.now().toIso8601String();
      }
      if (cost != null) {
        updateData['cost'] = cost;
      }

      if (auditEntry != null) {
        final current = await _supabase.from('maintenance_logs').select('audit_log').eq('id', id).single();
        List<dynamic> logs = current['audit_log'] ?? [];
        logs.add({
          ...auditEntry,
          'timestamp': DateTime.now().toIso8601String(),
        });
        updateData['audit_log'] = logs;
      }

      await _supabase.from('maintenance_logs').update(updateData).eq('id', id);
    } catch (e) {
      throw Exception('Gagal memperbarui status: $e');
    }
  }

  Future<Map<String, dynamic>> getMaintenanceStats() async {
    try {
      final totalCostRes = await _supabase.rpc('get_total_maintenance_cost');
      final topDamagedRes = await _supabase.from('maintenance_logs')
          .select('item_id, items(name)')
          .limit(5);
      
      final pendingCount = await _supabase.from('maintenance_logs').select('id').eq('status', 'pending').count(CountOption.exact);
      final processCount = await _supabase.from('maintenance_logs').select('id').eq('status', 'perbaikan').count(CountOption.exact);

      return {
        'total_cost': totalCostRes ?? 0,
        'pending': pendingCount.count,
        'in_progress': processCount.count,
        'top_damaged': topDamagedRes,
      };
    } catch (e) {
      return {'total_cost': 0, 'pending': 0, 'in_progress': 0, 'top_damaged': []};
    }
  }
}
