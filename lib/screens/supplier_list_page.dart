import 'package:flutter/material.dart';
import '../models/supplier.dart';

class SupplierListPage extends StatelessWidget {
  const SupplierListPage({super.key});

  final List<Supplier> _suppliers = const [
    Supplier(
      id: 'S001',
      name: 'Kimia Farma Trading',
      address: 'Jl. Budi Utomo No. 1, Jakarta Pusat',
      pic: 'Bp. Heru',
      phone: '021-3456789',
      email: 'contact@kimiafarma.id',
    ),
    Supplier(
      id: 'S002',
      name: 'OneMed Healthcare',
      address: 'Kawasan Industri Jababeka, Bekasi',
      pic: 'Ibu Maya',
      phone: '021-8987654',
      email: 'sales@onemed.com',
    ),
    Supplier(
      id: 'S003',
      name: 'Sritex Medical Division',
      address: 'Solo, Jawa Tengah',
      pic: 'Bp. Andi',
      phone: '0271-555444',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Direktori Supplier'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _suppliers.length,
        itemBuilder: (context, index) {
          final s = _suppliers[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.business, color: Colors.blue),
              ),
              title: Text(
                s.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(s.address, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('PIC: ${s.pic}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                      const SizedBox(width: 16),
                      const Icon(Icons.phone, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(s.phone, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                    ],
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Supplier'),
      ),
    );
  }
}
