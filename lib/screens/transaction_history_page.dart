import 'package:flutter/material.dart';
import '../services/inventory_repository.dart';
import 'package:intl/intl.dart';

class TransactionHistoryPage extends StatefulWidget {
  final String title;
  final String? type; // 'masuk', 'keluar', 'mutasi'
  
  const TransactionHistoryPage({super.key, required this.title, this.type});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final InventoryRepository _repo = InventoryRepository();
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repo.getStockTransactions(type: widget.type);
      setState(() {
        _transactions = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat transaksi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: _fetchTransactions, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchTransactions,
              child: _transactions.isEmpty
                  ? const Center(child: Text('Belum ada riwayat transaksi.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final t = _transactions[index];
                        final type = t['type'] ?? 'umum';
                        final date = DateTime.parse(t['created_at']);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _getColor(type).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(_getIcon(type), color: _getColor(type), size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${t['items']?['name'] ?? 'Barang'} (${t['quantity']} unit)',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      'Oleh: ${t['profiles']?['full_name'] ?? 'Staf'} • ${t['description'] ?? '-'}',
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    DateFormat('HH:mm').format(date),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                                  ),
                                  Text(
                                    DateFormat('dd MMM').format(date),
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Color _getColor(String type) {
    if (type == 'masuk') return Colors.green;
    if (type == 'keluar') return Colors.red;
    return Colors.blue;
  }

  IconData _getIcon(String type) {
    if (type == 'masuk') return Icons.download;
    if (type == 'keluar') return Icons.upload;
    return Icons.swap_horiz;
  }
}
