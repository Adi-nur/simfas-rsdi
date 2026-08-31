import 'package:flutter/material.dart';
import '../services/inventory_repository.dart';
import '../services/auth_service.dart';
import '../models/maintenance_log.dart';
import '../models/user_role.dart';
import 'report_damage_page.dart';
import 'package:intl/intl.dart';

import 'maintenance_analytics_screen.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  final AuthService _auth = AuthService();
  final InventoryRepository _repo = InventoryRepository();
  List<MaintenanceLog> _allLogs = [];
  List<MaintenanceLog> _filteredLogs = [];
  bool _isLoading = true;
  String _searchQuery = "";
  MaintenanceStatus? _statusFilter;

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
        _allLogs = data.map((m) => MaintenanceLog.fromMap(m)).toList();
        _applyFilters();
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

  void _applyFilters() {
    setState(() {
      _filteredLogs = _allLogs.where((log) {
        final matchesSearch = log.itemName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                             log.reporterName.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesStatus = _statusFilter == null || log.status == _statusFilter;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pemeliharaan & Kerusakan'),
        actions: [
          if (_auth.currentRole == UserRole.direktur)
             IconButton(
               onPressed: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => const MaintenanceAnalyticsScreen()),
                 );
               },
               icon: const Icon(Icons.bar_chart),
             ),
          IconButton(onPressed: _fetchLogs, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchLogs,
                    child: _filteredLogs.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredLogs.length,
                            itemBuilder: (context, index) => _buildLogCard(_filteredLogs[index]),
                          ),
                  ),
          ),
        ],
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

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            onChanged: (v) {
              _searchQuery = v;
              _applyFilters();
            },
            decoration: InputDecoration(
              hintText: 'Cari barang atau pelapor...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(null, 'Semua'),
                _buildFilterChip(MaintenanceStatus.pending, 'Pending'),
                _buildFilterChip(MaintenanceStatus.perbaikan, 'Proses'),
                _buildFilterChip(MaintenanceStatus.selesai, 'Selesai'),
                _buildFilterChip(MaintenanceStatus.rusakTotal, 'Rusak Total'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip(MaintenanceStatus? status, String label) {
    final isSelected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _statusFilter = status;
            _applyFilters();
          });
        },
        selectedColor: const Color(0xFF0D47A1),
        checkmarkColor: Colors.white,
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(log.status).withOpacity(0.1),
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
                if (log.photoUrl != null) 
                  Container(
                    height: 150,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(image: NetworkImage(log.photoUrl!), fit: BoxFit.cover),
                    ),
                  ),
                _buildInfoRow('Lokasi', log.location ?? 'Tidak ditentukan', Colors.black87),
                const SizedBox(height: 8),
                _buildInfoRow('Tingkat', log.damageLevel.name.toUpperCase(), _getDamageColor(log.damageLevel)),
                const SizedBox(height: 8),
                _buildInfoRow('Deskripsi', log.description, Colors.black87),
                const SizedBox(height: 8),
                _buildInfoRow('Petugas', log.assignedToName ?? 'Belum ditugaskan', Colors.blue),
                if (log.estimatedFinish != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Estimasi Selesai', DateFormat('dd MMM yyyy').format(log.estimatedFinish!), Colors.orange),
                ],
                const SizedBox(height: 8),
                _buildInfoRow('Biaya Perbaikan', currencyFormat.format(log.cost), Colors.blueGrey),
                
                const SizedBox(height: 16),
                
                // Kontrol untuk Admin/Petugas
                if (_auth.showOperationalTasks() && 
                    log.status != MaintenanceStatus.selesai && 
                    log.status != MaintenanceStatus.rusakTotal)
                  Column(
                    children: [
                      if (log.status == MaintenanceStatus.pending)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showAssignDialog(log),
                            icon: const Icon(Icons.person_add),
                            label: const Text('TUGASKAN PETUGAS'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _updateStatus(log.id, 'rusak_total', auditEntry: {'action': 'Ditandai Rusak Total'}),
                              child: const Text('RUSAK TOTAL', style: TextStyle(color: Colors.red)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              onPressed: () => _showCompleteDialog(log),
                              child: const Text('SELESAI'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                // Tampilan Audit Trail Sederhana
                if (log.auditLog != null && log.auditLog!.isNotEmpty) ...[
                  const Divider(),
                  const Text('Riwayat Audit:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ...log.auditLog!.map((e) => Text(
                    '• ${DateFormat('HH:mm').format(DateTime.parse(e['timestamp']))}: ${e['action']}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  )),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showAssignDialog(MaintenanceLog log) async {
    try {
      final staff = await _repo.getStaffProfiles();
      if (!mounted) return;
      
      Map<String, dynamic>? selectedStaff;
      DateTime selectedDate = DateTime.now().add(const Duration(days: 3));

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Tugaskan Petugas'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Map<String, dynamic>>(
                  decoration: const InputDecoration(labelText: 'Pilih Petugas'),
                  items: staff.map((s) => DropdownMenuItem(value: s, child: Text(s['full_name']))).toList(),
                  onChanged: (v) => setDialogState(() => selectedStaff = v),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Estimasi Selesai'),
                  subtitle: Text(DateFormat('dd MMMM yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context, 
                      initialDate: selectedDate, 
                      firstDate: DateTime.now(), 
                      lastDate: DateTime.now().add(const Duration(days: 30))
                    );
                    if (picked != null) setDialogState(() => selectedDate = picked);
                  },
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
              ElevatedButton(
                onPressed: selectedStaff == null ? null : () {
                  Navigator.pop(context);
                  _assignPetugas(log.id, selectedStaff!['id'], selectedDate);
                },
                child: const Text('Tugaskan'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat staf: $e')));
    }
  }

  Future<void> _assignPetugas(String id, String petugasId, DateTime estimate) async {
    try {
      await _repo.assignMaintenance(id, petugasId, estimate);
      _fetchLogs();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Petugas ditugaskan'), backgroundColor: Colors.blue));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
    }
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
              _updateStatus(log.id, 'selesai', cost: cost, auditEntry: {'action': 'Perbaikan Selesai (Biaya: Rp $cost)'});
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String id, String status, {double? cost, Map<String, dynamic>? auditEntry}) async {
    try {
      await _repo.updateMaintenanceStatus(id, status, cost: cost, auditEntry: auditEntry);
      _fetchLogs();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status diperbarui'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
    }
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
