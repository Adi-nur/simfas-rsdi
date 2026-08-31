import 'package:flutter/material.dart';
import '../services/inventory_repository.dart';
import 'package:intl/intl.dart';

class MaintenanceAnalyticsScreen extends StatefulWidget {
  const MaintenanceAnalyticsScreen({super.key});

  @override
  State<MaintenanceAnalyticsScreen> createState() => _MaintenanceAnalyticsScreenState();
}

class _MaintenanceAnalyticsScreenState extends State<MaintenanceAnalyticsScreen> {
  final InventoryRepository _repo = InventoryRepository();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repo.getMaintenanceStats();
      setState(() {
        _stats = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Analitik Pemeliharaan')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchStats,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStatCard(
                  'Total Biaya Perbaikan', 
                  currencyFormat.format(_stats['total_cost']), 
                  Icons.account_balance_wallet, 
                  Colors.green
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Pending', _stats['pending'].toString(), Icons.timer, Colors.orange)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard('Proses', _stats['in_progress'].toString(), Icons.build, Colors.blue)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Top Aset Sering Rusak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(_stats['top_damaged'] as List).map((item) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.inventory_2)),
                    title: Text(item['items']['name']),
                    subtitle: const Text('Frekuensi kerusakan tinggi'),
                    trailing: const Icon(Icons.warning, color: Colors.amber),
                  ),
                )),
                if ((_stats['top_damaged'] as List).isEmpty)
                  const Center(child: Text('Data tidak tersedia', style: TextStyle(color: Colors.grey))),
                const SizedBox(height: 40),
                const Card(
                  color: Color(0xFFE3F2FD),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.insights, size: 40, color: Colors.blue),
                        SizedBox(height: 8),
                        Text(
                          'Saran Pengadaan:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        Text(
                          'Aset dengan biaya perbaikan > 50% harga beli disarankan untuk dilakukan penggantian unit baru.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
