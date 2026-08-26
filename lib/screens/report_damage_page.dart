import 'package:flutter/material.dart';
import '../services/inventory_repository.dart';

class ReportDamagePage extends StatefulWidget {
  const ReportDamagePage({super.key});

  @override
  State<ReportDamagePage> createState() => _ReportDamagePageState();
}

class _ReportDamagePageState extends State<ReportDamagePage> {
  final _repo = InventoryRepository();
  final _descController = TextEditingController();
  
  List<Map<String, dynamic>> _items = [];
  Map<String, dynamic>? _selectedItem;
  String _damageLevel = 'ringan';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    try {
      final data = await _repo.getAllItems();
      setState(() {
        _items = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReport() async {
    if (_selectedItem == null || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi semua data')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _repo.createMaintenanceReport(
        itemId: _selectedItem!['id'],
        description: _descController.text,
        damageLevel: _damageLevel,
      );
      if (mounted) {
        Navigator.pop(context);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan dikirim'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Lapor Kerusakan')),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilih Barang', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _items.map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item['name']),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedItem = v),
                  ),
                  const SizedBox(height: 20),
                  const Text('Tingkat Kerusakan', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _damageLevel,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'ringan', child: Text('Ringan')),
                      DropdownMenuItem(value: 'sedang', child: Text('Sedang')),
                      DropdownMenuItem(value: 'berat', child: Text('Berat / Parah')),
                    ],
                    onChanged: (v) => setState(() => _damageLevel = v!),
                  ),
                  const SizedBox(height: 20),
                  const Text('Deskripsi Kerusakan', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Jelaskan bagian mana yang rusak dan gejalanya...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
                      onPressed: _isSaving ? null : _submitReport,
                      child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('KIRIM LAPORAN'),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
