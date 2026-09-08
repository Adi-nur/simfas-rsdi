import 'package:flutter/material.dart';
import '../services/inventory_repository.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class ReportDamagePage extends StatefulWidget {
  const ReportDamagePage({super.key});

  @override
  State<ReportDamagePage> createState() => _ReportDamagePageState();
}

class _ReportDamagePageState extends State<ReportDamagePage> {
  final _repo = InventoryRepository();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _picker = ImagePicker();
  
  List<Map<String, dynamic>> _items = [];
  Map<String, dynamic>? _selectedItem;
  String _damageLevel = 'ringan';
  
  XFile? _pickedFile;
  Uint8List? _webImage;
  String? _photoUrl; 
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

  Future<void> _scanBarcode() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              Navigator.pop(context, barcodes.first.rawValue);
            }
          },
        ),
      ),
    );

    if (result != null) {
      try {
        final item = await _repo.getItemByCode(result);
        if (item != null) {
          setState(() {
            _selectedItem = _items.firstWhere((element) => element['id'] == item['id'], orElse: () => item);
          });
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Barang tidak ditemukan')));
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _pickedFile = image;
          _webImage = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
    }
  }

  Future<void> _submitReport() async {
    if (_selectedItem == null || _descController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi data (Barang, Lokasi, Deskripsi)')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Upload foto jika ada
      if (_pickedFile != null && _webImage != null) {
        final uploadedUrl = await _repo.uploadMaintenancePhoto(
          _pickedFile!.path, 
          _webImage!, 
          _pickedFile!.name
        );
        _photoUrl = uploadedUrl;
      }

      await _repo.createMaintenanceReport(
        itemId: _selectedItem!['id'],
        description: _descController.text,
        damageLevel: _damageLevel,
        location: _locationController.text,
        photoUrl: _photoUrl,
      );
      
      if (mounted) {
        Navigator.pop(context);
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pilih Barang', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: _scanBarcode,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Scan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedItem,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _items.map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item['name']),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedItem = v),
                  ),
                  const SizedBox(height: 20),
                  const Text('Lokasi / Ruangan', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Poli Umum, Lantai 2',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Tingkat Kerusakan', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _damageLevel,
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
                  const SizedBox(height: 20),
                  const Text('Lampiran Foto (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickPhoto,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _webImage != null 
                        ? Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(_webImage!, fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                top: 8, right: 8,
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: () => setState(() {
                                      _pickedFile = null;
                                      _webImage = null;
                                    }),
                                  ),
                                ),
                              )
                            ],
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                              Text('Ambil Foto Kerusakan', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
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
