import 'package:flutter/material.dart';
import 'transaction_history_page.dart';
import '../services/auth_service.dart';
import '../services/inventory_repository.dart';
import '../services/report_service.dart';
import '../models/user_role.dart';

class StockManagementPage extends StatelessWidget {
  const StockManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final repo = InventoryRepository();
    final report = ReportService();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Operasional & Stok')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (auth.showOperationalTasks()) ...[
            _buildMenuCard(context, 'Penerimaan Barang', 'Input stok masuk dari supplier', Icons.add_business, Colors.green),
            _buildMenuCard(context, 'Pengeluaran Barang', 'Distribusi barang ke unit/poli', Icons.local_shipping, Colors.red),
            _buildMenuCard(context, 'Mutasi Antar Gudang', 'Pindah stok antar lokasi', Icons.compare_arrows, Colors.blue),
          ],
          
          if (auth.canApproveRequests())
            _buildMenuCard(context, 'Persetujuan (Approval)', 'Konfirmasi permintaan dari unit', Icons.fact_check, Colors.teal),

          if (auth.currentRole == UserRole.unitPoli)
            _buildMenuCard(context, 'Permintaan Baru', 'Ajukan kebutuhan barang unit', Icons.add_shopping_cart, Colors.indigo),

          _buildMenuCard(context, 'Stock Opname', 'Audit fisik barang di gudang', Icons.inventory, Colors.orange),

          if (auth.canViewAnalytics())
            _buildMenuCard(
              context, 
              'Cetak Laporan Stok', 
              'Generasi PDF persediaan barang', 
              Icons.picture_as_pdf, 
              Colors.redAccent,
              onTap: () async {
                try {
                  final items = await repo.getAllItems();
                  await report.generateInventoryReport(items);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal cetak: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            ),
          
          if (auth.currentRole == UserRole.superAdmin)
            _buildMenuCard(context, 'Audit Log Sistem', 'Pantau semua perubahan data', Icons.security, Colors.blueGrey),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, String sub, IconData icon, Color color, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap ?? () => Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionHistoryPage(title: title))),
      ),
    );
  }
}
