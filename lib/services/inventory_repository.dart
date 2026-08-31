import 'package:supabase_flutter/supabase_flutter.dart';

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
    try {
      final itemsRes = await _supabase.from('items').select('id').count(CountOption.exact);
      final lowStockRes = await _supabase.from('items').select('id').filter('stock', 'lt', 'min_stock').count(CountOption.exact);
      final pendingReqRes = await _supabase.from('requests').select('id').eq('status', 'pending').count(CountOption.exact);
      
      final totalAsetResult = await _supabase.rpc('get_total_inventory_value');
      
      return {
        'total_items': itemsRes.count,
        'low_stock': lowStockRes.count,
        'pending_requests': pendingReqRes.count,
        'total_value': totalAsetResult ?? 0,
      };
    } catch (e) {
      return {
        'total_items': 0,
        'low_stock': 0,
        'pending_requests': 0,
        'total_value': 0,
      };
    }
  }

  // Ambil profil staf untuk penugasan
  Future<List<Map<String, dynamic>>> getStaffProfiles() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, full_name, role')
          .inFilter('role', ['super_admin', 'petugas_gudang', 'kepala_gudang']);
      return response;
    } catch (e) {
      throw Exception('Gagal memuat profil staf: $e');
    }
  }

  // ==========================================
  // PEMELIHARAAN & KERUSAKAN (ENHANCED)
  // ==========================================

  Future<List<Map<String, dynamic>>> getMaintenanceLogs() async {
    try {
      final response = await _supabase
          .from('maintenance_logs')
          .select('*, items(name), profiles:profiles!maintenance_logs_reporter_id_fkey(full_name), assignee:profiles!maintenance_logs_assigned_to_fkey(full_name)')
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

      // Handle Audit Log (Append to existing jsonb array if possible, or just overwrite for now as a simple implementation)
      // In a real Supabase setup, you might use a separate table or a more complex RPC to append to JSONB.
      // For this implementation, we assume the UI provides the new log entry.
      if (auditEntry != null) {
        // Fetch current audit log first
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
          .limit(5); // In a real app, you'd use a grouped query or RPC
      
      final pendingCount = await _supabase.from('maintenance_logs').select('id').eq('status', 'pending').count(CountOption.exact);
      final processCount = await _supabase.from('maintenance_logs').select('id').eq('status', 'perbaikan').count(CountOption.exact);

      return {
        'total_cost': totalCostRes ?? 0,
        'pending': pendingCount.count,
        'in_progress': processCount.count,
        'top_damaged': topDamagedRes, // Mockup structure
      };
    } catch (e) {
      return {'total_cost': 0, 'pending': 0, 'in_progress': 0, 'top_damaged': []};
    }
  }
}
