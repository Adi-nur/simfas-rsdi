import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/inventory_item.dart';
import 'add_item_page.dart';

import '../services/inventory_repository.dart';
import '../services/auth_service.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  final AuthService _auth = AuthService();
  final InventoryRepository _repo = InventoryRepository();
  List<InventoryItem> _items = [];
  List<InventoryItem> _filteredItems = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = "";
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _repo.getAllItems();
      if (!mounted) return;
      setState(() {
        _items = data.map((item) => InventoryItem.fromMap(item)).toList();
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredItems = List.from(_items);
      } else {
        final query = _searchQuery.toLowerCase();
        _filteredItems = _items.where((item) {
          return item.name.toLowerCase().contains(query) ||
                 item.code.toLowerCase().contains(query) ||
                 item.categoryName.toLowerCase().contains(query) ||
                 item.location.toLowerCase().contains(query) ||
                 item.supplier.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  double get _totalAssetValue {
    double sum = 0;
    for (var item in _items) {
      sum += (item.stock * item.price);
    }
    return sum;
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  void _confirmDelete(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Apakah Anda yakin ingin menghapus "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteItem(item.id);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(String id) async {
    try {
      await _repo.deleteItem(id);
      _fetchItems();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barang berhasil dihapus'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Aset Inventaris',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Text(
                _formatCurrency(_totalAssetValue),
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${_items.length} Jenis Barang Terdaftar',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                style: const TextStyle(color: Color(0xFF1E293B)),
                decoration: const InputDecoration(
                  hintText: 'Cari nama, kode, lokasi...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  _searchQuery = value;
                  _applyFilters();
                },
              )
            : const Text('Daftar Inventaris'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = "";
                  _applyFilters();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchItems,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Terjadi kesalahan: $_error', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _fetchItems, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildSummaryCard(),
                    Expanded(
                      child: _filteredItems.isEmpty
                          ? const Center(child: Text('Tidak ada data barang.'))
                          : RefreshIndicator(
                              onRefresh: _fetchItems,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                                itemCount: _filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = _filteredItems[index];
                                  final isLowStock = item.stock < item.minStock;
                                  final itemTotalValue = item.stock * item.price;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isLowStock ? Colors.red.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.02),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      leading: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(item.category).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _getCategoryIcon(item.category),
                                          color: _getCategoryColor(item.category),
                                          size: 24,
                                        ),
                                      ),
                                      title: Text(
                                        item.name,
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text('${item.code} • ${item.categoryName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.sell_outlined, size: 12, color: Colors.blueGrey),
                                              const SizedBox(width: 4),
                                              Text('Harga: ${_formatCurrency(item.price)} / ${item.unit}', style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              const Icon(Icons.account_balance_wallet_outlined, size: 12, color: Colors.teal),
                                              const SizedBox(width: 4),
                                              Text('Nilai Aset: ${_formatCurrency(itemTotalValue)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal)),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(item.location, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${item.stock} ${item.unit}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w900,
                                                  color: isLowStock ? Colors.red : const Color(0xFF0F172A),
                                                ),
                                              ),
                                              if (isLowStock)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Text(
                                                    'LOW STOCK',
                                                    style: TextStyle(color: Colors.red, fontSize: 8, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          if (_auth.canAccessMasterData()) ...[
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                                              onPressed: () => _confirmDelete(item),
                                              tooltip: 'Hapus Barang',
                                            ),
                                          ],
                                        ],
                                      ),
                                      onTap: () {},
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddItemPage()));
          if (result == true) {
            _fetchItems();
          }
        },
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Barang Baru'),
      ),
    );
  }

  Color _getCategoryColor(ItemCategory category) {
    switch (category) {
      case ItemCategory.obat: return Colors.blue;
      case ItemCategory.alatMedis: return Colors.teal;
      case ItemCategory.apd: return Colors.orange;
      case ItemCategory.bahanHabisPakai: return Colors.purple;
      default: return Colors.blueGrey;
    }
  }

  IconData _getCategoryIcon(ItemCategory category) {
    switch (category) {
      case ItemCategory.obat: return Icons.medication;
      case ItemCategory.alatMedis: return Icons.biotech;
      case ItemCategory.apd: return Icons.masks;
      case ItemCategory.bahanHabisPakai: return Icons.science;
      default: return Icons.inventory_2;
    }
  }
}
