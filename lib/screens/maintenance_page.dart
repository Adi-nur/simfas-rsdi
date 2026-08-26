import 'package:flutter/material.dart';
import '../services/inventory_repository.dart';
import '../services/auth_service.dart';
import '../models/maintenance_log.dart';
import '../models/user_role.dart';
import 'report_damage_page.dart';
import 'package:intl/intl.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  final AuthService _auth = AuthService();
  final InventoryRepository _repo = InventoryRepository();
  List<MaintenanceLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repo.getMaintenanceLogs();
      setState(() {
        _logs = data.map((m) => MaintenanceLog.fromMap(m)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pemeliharaan & Kerusakan'),
        actions: [
          IconButton(onPressed: _fetchLogs, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchLogs,
              child: _logs.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _logs.length,
                      itemBuilder: (context, index) => _buildLogCard(_logs[index]),
                    ),
            ),
      floatingActionButton: _auth.currentRole == UserRole.direktur 
          ? null 
          : FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportDamagePage()),
                );
                _fetchLogs();
              },
              backgroundColor: const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.report_problem),
              label: const Text('Lapor Kerusakan'),
            ),
    );
  }

  Widget _buildLogCard(MaintenanceLog log) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(log.status).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_getStatusIcon(log.status), color: _getStatusColor(log.status), size: 24),
        ),
        title: Text(log.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Pelapor: ${log.reporterName} • ${DateFormat('dd MMM yyyy').format(log.createdAt)}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Tingkat Kerusakan', log.damageLevel.name.toUpperCase(), _getDamageColor(log.damageLevel)),
                const SizedBox(height: 8),
                _buildInfoRow('Deskripsi', log.description, Colors.black87),
                const SizedBox(height: 8),
                _buildInfoRow('Biaya Perbaikan', currencyFormat.format(log.cost), Colors.blueGrey),
                const SizedBox(height: 16),
                
                // Hanya Admin atau Petugas Gudang yang bisa update status perbaikan
                if (_auth.showOperationalTasks() && 
                    log.status != MaintenanceStatus.selesai && 
                    log.status != MaintenanceStatus.rusakTotal)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _updateStatus(log.id, 'rusak_total'),
                          child: const Text('RUSAK TOTAL', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          onPressed: () => _showCompleteDialog(log),
                          child: const Text('SELESAI PERBAIKAN'),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))),
        Expanded(child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: valueColor))),
      ],
    );
  }

  void _showCompleteDialog(MaintenanceLog log) {
    final costController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Perbaikan'),
        content: TextField(
          controller: costController,
          decoration: const InputDecoration(labelText: 'Biaya Perbaikan (Rp)', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final cost = double.tryParse(costController.text) ?? 0;
              Navigator.pop(context);
              _updateStatus(log.id, 'selesai', cost: cost);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String id, String status, {double? cost}) async {
    try {
      await _repo.updateMaintenanceStatus(id, status, cost: cost);
      _fetchLogs();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status diperbarui'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Tidak ada laporan kerusakan', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Color _getStatusColor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.perbaikan: return Colors.orange;
      case MaintenanceStatus.selesai: return Colors.green;
      case MaintenanceStatus.rusakTotal: return Colors.red;
      default: return Colors.blue;
    }
  }

  IconData _getStatusIcon(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.perbaikan: return Icons.build;
      case MaintenanceStatus.selesai: return Icons.check_circle;
      case MaintenanceStatus.rusakTotal: return Icons.cancel;
      default: return Icons.timer;
    }
  }

  Color _getDamageColor(DamageLevel level) {
    switch (level) {
      case DamageLevel.sedang: return Colors.orange;
      case DamageLevel.berat: return Colors.red;
      default: return Colors.green;
    }
  }
}
