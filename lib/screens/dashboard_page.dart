import 'package:flutter/material.dart';
import 'transaction_history_page.dart';
import 'item_list_page.dart';
import 'scanner_page.dart';
import 'approval_list_page.dart';
import '../services/auth_service.dart';
import '../services/inventory_repository.dart';
import '../models/user_role.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthService _auth = AuthService();
  final InventoryRepository _repo = InventoryRepository();
  
  Map<String, dynamic> _stats = {
    'total_items': 0,
    'low_stock': 0,
    'pending_requests': 0,
    'total_value': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _repo.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfessionalHeader(context, _auth),
              const SizedBox(height: 28),
              
              _buildSectionTitle(context, _auth),
              const SizedBox(height: 12),
              
              _isLoading 
                ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                : _buildDynamicStatsGrid(context, _auth),
              
              const SizedBox(height: 30),
              
              if (_auth.canViewAnalytics()) ...[
                const Text(
                  'Analitik & Tren Stok',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 16),
                _buildProfessionalChartPlaceholder(),
                const SizedBox(height: 30),
              ],
              
              const Text(
                'Layanan Cepat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 16),
              _buildDynamicQuickActions(context, _auth),
      
              const SizedBox(height: 30),
      
              const Text(
                'Aktivitas Terkait Anda',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 12),
              _buildModernActivityList(context, _auth),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, AuthService auth) {
    String title = 'Ringkasan Logistik';
    if (auth.currentRole == UserRole.direktur) title = 'Ringkasan Eksekutif';
    if (auth.currentRole == UserRole.unitPoli) title = 'Status Permintaan Unit';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
        ),
        TextButton(
          onPressed: () => _navigateToHistory(context, 'Laporan Lengkap'),
          child: const Text('Detail'),
        ),
      ],
    );
  }

  Widget _buildDynamicStatsGrid(BuildContext context, AuthService auth) {
    List<Widget> cards = [];

    if (auth.currentRole == UserRole.direktur) {
      cards = [
        _buildStatCard(context, 'Total Aset', 'Rp ${_stats['total_value']}', Icons.account_balance_wallet, Colors.blue),
        _buildStatCard(context, 'Efisiensi Stok', '92%', Icons.trending_up, Colors.green),
        _buildStatCard(context, 'Stok Mati', '0', Icons.layers_clear, Colors.red),
        _buildStatCard(context, 'Vendor Aktif', '-', Icons.handshake, Colors.orange),
      ];
    } else if (auth.currentRole == UserRole.unitPoli) {
      cards = [
        _buildStatCard(context, 'Permintaan Selesai', '-', Icons.check_circle, Colors.green),
        _buildStatCard(context, 'Menunggu Approval', '${_stats['pending_requests']}', Icons.pending, Colors.orange),
        _buildStatCard(context, 'Ditolak/Revisi', '0', Icons.cancel, Colors.red),
        _buildStatCard(context, 'Item Tersedia', '${_stats['total_items']}', Icons.inventory, Colors.blue),
      ];
    } else {
      cards = [
        _buildStatCard(context, 'Total Item', '${_stats['total_items']}', Icons.inventory_2, Colors.blue),
        _buildStatCard(context, 'Stok Kritis', '${_stats['low_stock']}', Icons.report_problem, Colors.red),
        _buildStatCard(context, 'Expired (30hr)', '0', Icons.timer, Colors.orange),
        _buildStatCard(context, 'Req Pending', '${_stats['pending_requests']}', Icons.pending_actions, Colors.green),
      ];
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: cards,
    );
  }

  Widget _buildDynamicQuickActions(BuildContext context, AuthService auth) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (auth.canManageStock()) ...[
            _buildActionItem(context, 'Scan', Icons.qr_code_scanner, Colors.indigo, () async {
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (context) => const ScannerPage()),
              );
              if (result != null && result.isNotEmpty) {
                _handleSearchByCode(context, result);
              }
            }),
            _buildActionItem(context, 'Input Masuk', Icons.login, Colors.green, () => _navigateToHistory(context, 'Log Barang Masuk')),
            _buildActionItem(context, 'Mutasi', Icons.swap_horiz, Colors.orange, () => _navigateToHistory(context, 'Log Mutasi')),
          ],
          if (auth.currentRole == UserRole.unitPoli)
            _buildActionItem(context, 'Buat Request', Icons.add_shopping_cart, Colors.blue, () => _navigateToHistory(context, 'Form Permintaan')),
          
          if (auth.canApproveRequests())
            _buildActionItem(context, 'Approval', Icons.how_to_reg, Colors.teal, () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const ApprovalListPage()));
            }),

          _buildActionItem(context, 'Purchase', Icons.shopping_cart, Colors.purple, () => _navigateToHistory(context, 'Purchase Order')),
          
          if (auth.currentRole == UserRole.direktur)
            _buildActionItem(context, 'Laporan Keuangan', Icons.assessment, Colors.red, () => _navigateToHistory(context, 'Laporan Tahunan')),
        ],
      ),
    );
  }

  Future<void> _handleSearchByCode(BuildContext context, String code) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final item = await _repo.getItemByCode(code);
      if (mounted) Navigator.pop(context); // Close loading

      if (item != null) {
        if (mounted) _showItemDetails(context, item);
      } else {
        if (mounted) _showErrorSnackBar(context, 'Barang dengan kode $code tidak ditemukan di database.');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) _showErrorSnackBar(context, 'Error saat mencari data: $e');
    }
  }

  void _showItemDetails(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Data Barang Ditemukan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medication, color: Colors.blue, size: 48),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'] ?? 'Tanpa Nama', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Kode: ${item['code']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('Stok Saat Ini: ${item['stock'] ?? 0} Unit', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('TAMBAH STOK'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('KELUARKAN'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }

  void _navigateToHistory(BuildContext context, String title) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionHistoryPage(title: title)));
  }

  Widget _buildProfessionalHeader(BuildContext context, AuthService auth) {
    final role = auth.currentRole;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_roleLabel(role), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('Selamat Bekerja!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalChartPlaceholder() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(child: Icon(Icons.bar_chart, size: 60, color: Colors.grey)),
    );
  }

  Widget _buildModernActivityList(BuildContext context, AuthService auth) {
    String activityText = auth.currentRole == UserRole.unitPoli ? 'Permintaan disetujui' : 'Barang masuk dari supplier';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.circle, size: 12, color: Colors.blue),
          title: Text(activityText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          subtitle: const Text('Baru saja', style: TextStyle(fontSize: 11)),
        ),
      ),
    );
  }

  String _roleLabel(UserRole? role) {
    if (role == null) return 'Staf';
    switch (role) {
      case UserRole.superAdmin: return 'Super Admin';
      case UserRole.kepalaGudang: return 'Kepala Gudang';
      case UserRole.petugasGudang: return 'Petugas Gudang';
      case UserRole.unitPoli: return 'Unit / Poli';
      case UserRole.direktur: return 'Direktur';
    }
  }
}
