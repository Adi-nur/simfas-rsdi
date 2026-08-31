import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../services/inventory_repository.dart';

class SupplierListPage extends StatefulWidget {
  const SupplierListPage({super.key});

  @override
  State<SupplierListPage> createState() => _SupplierListPageState();
}

class _SupplierListPageState extends State<SupplierListPage> {
  final InventoryRepository _repo = InventoryRepository();
  List<Supplier> _suppliers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  Future<void> _fetchSuppliers() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repo.getSuppliers();
      setState(() {
        _suppliers = data.map((s) => Supplier.fromMap(s)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat supplier: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Direktori Supplier'),
        actions: [
          IconButton(onPressed: _fetchSuppliers, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchSuppliers,
              child: _suppliers.isEmpty
                  ? const Center(child: Text('Belum ada data supplier.'))
                  : ListView.builder(
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
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSupplierDialog(context),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Supplier'),
      ),
    );
  }

  void _showAddSupplierDialog(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final picController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tambah Supplier Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Perusahaan', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Alamat', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: picController, decoration: const InputDecoration(labelText: 'Nama PIC', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Nomor Telepon', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
                    onPressed: isSaving ? null : () async {
                      if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama dan Telepon wajib diisi')));
                        return;
                      }
                      setModalState(() => isSaving = true);
                      try {
                        await _repo.addSupplier({
                          'name': nameController.text.trim(),
                          'address': addressController.text.trim(),
                          'pic': picController.text.trim(),
                          'phone': phoneController.text.trim(),
                          'email': emailController.text.trim(),
                        });
                        if (context.mounted) {
                          Navigator.pop(context);
                          _fetchSuppliers();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Supplier berhasil ditambahkan'), backgroundColor: Colors.green));
                        }
                      } catch (e) {
                        setModalState(() => isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                      }
                    },
                    child: isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('SIMPAN SUPPLIER'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
