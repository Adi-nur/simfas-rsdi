import 'package:flutter/material.dart';

class TransactionHistoryPage extends StatelessWidget {
  final String title;
  const TransactionHistoryPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
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
                    color: _getColor(index).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getIcon(index), color: _getColor(index), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTitle(index),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Oleh: Suster Rina • Gudang $index',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '12:45',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                    ),
                    Text(
                      '${index + 1} item',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getColor(int index) {
    if (index % 3 == 0) return Colors.green;
    if (index % 3 == 1) return Colors.red;
    return Colors.blue;
  }

  IconData _getIcon(int index) {
    if (index % 3 == 0) return Icons.download;
    if (index % 3 == 1) return Icons.upload;
    return Icons.swap_horiz;
  }

  String _getTitle(int index) {
    if (index % 3 == 0) return 'Barang Masuk: Amoxicillin';
    if (index % 3 == 1) return 'Barang Keluar: Masker Bedah';
    return 'Mutasi: Gudang Farmasi ke IGD';
  }
}
