import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/inventory_repository.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  final InventoryRepository _repo = InventoryRepository();
  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  bool _isLoading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repo.getCategories();
      if (!mounted) return;
      setState(() {
        _allCategories = data.map((c) => Category.fromMap(c)).toList();
        _applySearch();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat kategori: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _applySearch() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredCategories = List.from(_allCategories);
      } else {
        final query = _searchQuery.toLowerCase();
        _filteredCategories = _allCategories.where((c) {
          return c.name.toLowerCase().contains(query) ||
                 c.code.toLowerCase().contains(query) ||
                 c.description.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Kategori Barang'),
        actions: [
          IconButton(onPressed: _fetchCategories, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                _searchQuery = value;
                _applySearch();
              },
              decoration: InputDecoration(
                hintText: 'Cari nama, kode, atau deskripsi...',
                prefixIcon: const Icon(Icons.search, color: Colors.blueGrey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchCategories,
                    child: _filteredCategories.isEmpty
                        ? const Center(child: Text('Belum ada data kategori.'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredCategories.length,
                            itemBuilder: (context, index) {
                              final cat = _filteredCategories[index];
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
                                      color: Colors.purple.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.category_rounded, color: Colors.purple),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          cat.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ),
                                      if (cat.code.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            cat.code.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.purple,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      cat.description.isNotEmpty ? cat.description : 'Tidak ada deskripsi',
                                      style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                                    ),
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.blueGrey),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showEditCategorySheet(context, cat);
                                      } else if (value == 'delete') {
                                        _confirmDeleteCategory(context, cat);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, color: Colors.blue, size: 20),
                                            SizedBox(width: 8),
                                            Text('Edit Kategori'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red, size: 20),
                                            SizedBox(width: 8),
                                            Text('Hapus Kategori', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategorySheet(context),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kategori'),
      ),
    );
  }

  void _showAddCategorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddCategorySheet(
        repo: _repo,
        onSuccess: _fetchCategories,
      ),
    );
  }

  void _showEditCategorySheet(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _EditCategorySheet(
        category: category,
        repo: _repo,
        onSuccess: _fetchCategories,
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (_) => _DeleteCategoryDialog(
        category: category,
        repo: _repo,
        onSuccess: _fetchCategories,
      ),
    );
  }
}

class _AddCategorySheet extends StatefulWidget {
  final InventoryRepository repo;
  final VoidCallback onSuccess;

  const _AddCategorySheet({required this.repo, required this.onSuccess});

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descController.dispose();
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
            const Text('Tambah Kategori Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Kategori', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _codeController, decoration: const InputDecoration(labelText: 'Kode Kategori (Misal: OBT, ALK)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _descController, maxLines: 2, decoration: const InputDecoration(labelText: 'Deskripsi Kategori', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
                onPressed: _isSaving ? null : _saveCategory,
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('SIMPAN KATEGORI'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama Kategori wajib diisi')));
      return;
    }
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await widget.repo.addCategory({
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim().toUpperCase(),
        'description': _descController.text.trim(),
      });
      navigator.pop();
      widget.onSuccess();
      messenger.showSnackBar(const SnackBar(content: Text('Kategori berhasil ditambahkan'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }
}

class _EditCategorySheet extends StatefulWidget {
  final Category category;
  final InventoryRepository repo;
  final VoidCallback onSuccess;

  const _EditCategorySheet({
    required this.category,
    required this.repo,
    required this.onSuccess,
  });

  @override
  State<_EditCategorySheet> createState() => _EditCategorySheetState();
}

class _EditCategorySheetState extends State<_EditCategorySheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _descController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _codeController = TextEditingController(text: widget.category.code);
    _descController = TextEditingController(text: widget.category.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descController.dispose();
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
            const Text('Edit Kategori Barang', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Kategori', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _codeController, decoration: const InputDecoration(labelText: 'Kode Kategori', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _descController, maxLines: 2, decoration: const InputDecoration(labelText: 'Deskripsi Kategori', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
                onPressed: _isSaving ? null : _updateCategory,
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('PERBARUI KATEGORI'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _updateCategory() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama Kategori wajib diisi')));
      return;
    }
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await widget.repo.updateCategory(widget.category.id, {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim().toUpperCase(),
        'description': _descController.text.trim(),
      });
      navigator.pop();
      widget.onSuccess();
      messenger.showSnackBar(
        const SnackBar(content: Text('Kategori berhasil diperbarui'), backgroundColor: Colors.green),
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

class _DeleteCategoryDialog extends StatefulWidget {
  final Category category;
  final InventoryRepository repo;
  final VoidCallback onSuccess;

  const _DeleteCategoryDialog({
    required this.category,
    required this.repo,
    required this.onSuccess,
  });

  @override
  State<_DeleteCategoryDialog> createState() => _DeleteCategoryDialogState();
}

class _DeleteCategoryDialogState extends State<_DeleteCategoryDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hapus Kategori'),
      content: Text('Apakah Anda yakin ingin menghapus kategori "${widget.category.name}"?'),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: _isDeleting ? null : _deleteCategory,
          child: _isDeleting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Hapus'),
        ),
      ],
    );
  }

  Future<void> _deleteCategory() async {
    setState(() => _isDeleting = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await widget.repo.deleteCategory(widget.category.id);
      navigator.pop();
      widget.onSuccess();
      messenger.showSnackBar(
        const SnackBar(content: Text('Kategori berhasil dihapus'), backgroundColor: Colors.green),
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
