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
      if (!mounted) return;
      setState(() {
        _suppliers = data.map((s) => Supplier.fromMap(s)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat supplier: $e'), backgroundColor: Colors.red),
      );
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
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 4,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.person, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text('PIC: ${s.pic}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.phone, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(s.phone, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                                      ],
                                    ),
                                    if (s.email != null && s.email!.isNotEmpty)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.email, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(s.email!, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Colors.blueGrey),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditSupplierDialog(context, s);
                                } else if (value == 'delete') {
                                  _confirmDeleteSupplier(context, s);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.blue, size: 20),
                                      SizedBox(width: 8),
                                      Text('Edit Supplier'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red, size: 20),
                                      SizedBox(width: 8),
                                      Text('Hapus Supplier', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddSupplierSheet(
        repo: _repo,
        onSuccess: _fetchSuppliers,
      ),
    );
  }

  void _showEditSupplierDialog(BuildContext context, Supplier supplier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _EditSupplierSheet(
        supplier: supplier,
        repo: _repo,
        onSuccess: _fetchSuppliers,
      ),
    );
  }

  void _confirmDeleteSupplier(BuildContext context, Supplier supplier) {
    showDialog(
      context: context,
      builder: (_) => _DeleteSupplierDialog(
        supplier: supplier,
        repo: _repo,
        onSuccess: _fetchSuppliers,
      ),
    );
  }
}

class _AddSupplierSheet extends StatefulWidget {
  final InventoryRepository repo;
  final VoidCallback onSuccess;

  const _AddSupplierSheet({required this.repo, required this.onSuccess});

  @override
  State<_AddSupplierSheet> createState() => _AddSupplierSheetState();
}

class _AddSupplierSheetState extends State<_AddSupplierSheet> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _picController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _picController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Perusahaan', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Alamat', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _picController, decoration: const InputDecoration(labelText: 'Nama PIC', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Nomor Telepon', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
                onPressed: _isSaving ? null : _saveSupplier,
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('SIMPAN SUPPLIER'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSupplier() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama dan Telepon wajib diisi')));
      return;
    }
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await widget.repo.addSupplier({
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'pic': _picController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
      });
      navigator.pop();
      widget.onSuccess();
      messenger.showSnackBar(const SnackBar(content: Text('Supplier berhasil ditambahkan'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }
}

class _EditSupplierSheet extends StatefulWidget {
  final Supplier supplier;
  final InventoryRepository repo;
  final VoidCallback onSuccess;

  const _EditSupplierSheet({
    required this.supplier,
    required this.repo,
    required this.onSuccess,
  });

  @override
  State<_EditSupplierSheet> createState() => _EditSupplierSheetState();
}

class _EditSupplierSheetState extends State<_EditSupplierSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _picController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier.name);
    _addressController = TextEditingController(text: widget.supplier.address);
    _picController = TextEditingController(text: widget.supplier.pic);
    _phoneController = TextEditingController(text: widget.supplier.phone);
    _emailController = TextEditingController(text: widget.supplier.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _picController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            const Text('Edit Data Supplier', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Perusahaan', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Alamat', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _picController, decoration: const InputDecoration(labelText: 'Nama PIC', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Nomor Telepon', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
                onPressed: _isSaving ? null : _updateSupplier,
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('PERBARUI SUPPLIER'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _updateSupplier() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama dan Telepon wajib diisi')));
      return;
    }
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await widget.repo.updateSupplier(widget.supplier.id, {
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'pic': _picController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
      });
      navigator.pop();
      widget.onSuccess();
      messenger.showSnackBar(
        const SnackBar(content: Text('Supplier berhasil diperbarui'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

class _DeleteSupplierDialog extends StatefulWidget {
  final Supplier supplier;
  final InventoryRepository repo;
  final VoidCallback onSuccess;

  const _DeleteSupplierDialog({
    required this.supplier,
    required this.repo,
    required this.onSuccess,
  });

  @override
  State<_DeleteSupplierDialog> createState() => _DeleteSupplierDialogState();
}

class _DeleteSupplierDialogState extends State<_DeleteSupplierDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hapus Supplier'),
      content: Text('Apakah Anda yakin ingin menghapus supplier "${widget.supplier.name}"?'),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: _isDeleting ? null : _deleteSupplier,
          child: _isDeleting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Hapus'),
        ),
      ],
    );
  }

  Future<void> _deleteSupplier() async {
    setState(() => _isDeleting = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await widget.repo.deleteSupplier(widget.supplier.id);
      navigator.pop();
      widget.onSuccess();
      messenger.showSnackBar(
        const SnackBar(content: Text('Supplier berhasil dihapus'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
