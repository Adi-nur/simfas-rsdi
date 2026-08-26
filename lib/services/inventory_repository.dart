import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryRepository {
  final _supabase = Supabase.instance.client;

  // Mendapatkan semua item barang
  Future<List<Map<String, dynamic>>> getAllItems() async {
    try {
      final response = await _supabase
          .from('items')
          .select('*, categories(name)')
          .order('name');
      return response;
    } catch (e) {
      throw Exception('Gagal memuat data barang: $e');
    }
  }

  // Mendapatkan stok berdasarkan batch (FEFO ready)
  Future<List<Map<String, dynamic>>> getItemStocks(int itemId) async {
    try {
      final response = await _supabase
          .from('inventory_stocks')
          .select('*')
          .eq('item_id', itemId)
          .order('expired_date', ascending: true);
      return response;
    } catch (e) {
      throw Exception('Gagal memuat stok batch: $e');
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

  // Membuat transaksi stok (Masuk/Keluar)
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
      
      // Catatan: Biasanya kita gunakan Database Trigger di Supabase 
      // untuk otomatis update quantity di tabel inventory_stocks
    } catch (e) {
      throw Exception('Gagal menyimpan transaksi: $e');
    }
  }

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

  // Dashboard Stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final itemsRes = await _supabase.from('items').select('id').count(CountOption.exact);
      final lowStockRes = await _supabase.from('items').select('id').filter('stock', 'lt', 'min_stock').count(CountOption.exact);
      final pendingReqRes = await _supabase.from('requests').select('id').eq('status', 'pending').count(CountOption.exact);
      
      // Hitung total aset (asumsi ada kolom price dan stock)
      final totalAsetResult = await _supabase.rpc('get_total_inventory_value');
      
      return {
        'total_items': itemsRes.count,
        'low_stock': lowStockRes.count,
        'pending_requests': pendingReqRes.count,
        'total_value': totalAsetResult ?? 0,
      };
    } catch (e) {
      // Jika RPC tidak ada, kembalikan data minimal
      return {
        'total_items': 0,
        'low_stock': 0,
        'pending_requests': 0,
        'total_value': 0,
      };
    }
  }

  // ==========================================
  // PEMELIHARAAN & KERUSAKAN
  // ==========================================

  // Ambil semua log pemeliharaan
  Future<List<Map<String, dynamic>>> getMaintenanceLogs() async {
    try {
      final response = await _supabase
          .from('maintenance_logs')
          .select('*, items(name), profiles:profiles(full_name)')
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      throw Exception('Gagal memuat data pemeliharaan: $e');
    }
  }

  // Buat laporan kerusakan baru
  Future<void> createMaintenanceReport({
    required int itemId,
    required String description,
    required String damageLevel,
  }) async {
    try {
      await _supabase.from('maintenance_logs').insert({
        'item_id': itemId,
        'reporter_id': _supabase.auth.currentUser?.id,
        'description': description,
        'damage_level': damageLevel,
        'status': 'pending',
      });
    } catch (e) {
      throw Exception('Gagal membuat laporan kerusakan: $e');
    }
  }

  // Update status pemeliharaan
  Future<void> updateMaintenanceStatus(String id, String status, {double? cost}) async {
    try {
      final Map<String, dynamic> updateData = {'status': status};
      if (status == 'selesai') {
        updateData['fixed_at'] = DateTime.now().toIso8601String();
      }
      if (cost != null) {
        updateData['cost'] = cost;
      }

      await _supabase.from('maintenance_logs').update(updateData).eq('id', id);
    } catch (e) {
      throw Exception('Gagal memperbarui status: $e');
    }
  }
}
