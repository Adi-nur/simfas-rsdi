enum ItemCategory {
  obat,
  alatMedis,
  bahanHabisPakai,
  apd,
  laboratorium,
  radiologi,
  atk,
  elektronik,
  furniture
}

class InventoryItem {
  final String id;
  final String code;
  final String name;
  final ItemCategory category;
  final String unit;
  final int stock;
  final int minStock;
  final double price;
  final DateTime? expiredDate;
  final String location;
  final String supplier;
  final String? batchNumber;
  final String? qrCode;
  final String? merk;

  InventoryItem({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    required this.unit,
    required this.stock,
    required this.minStock,
    required this.price,
    this.expiredDate,
    required this.location,
    required this.supplier,
    this.batchNumber,
    this.qrCode,
    this.merk,
  });

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id']?.toString() ?? '',
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      category: _mapStringToCategory(map['category'] ?? ''),
      unit: map['unit'] ?? '',
      stock: (map['stock'] ?? 0) as int,
      minStock: (map['min_stock'] ?? 0) as int,
      price: (map['price'] ?? 0.0).toDouble(),
      expiredDate: map['expired_date'] != null ? DateTime.parse(map['expired_date']) : null,
      location: map['location'] ?? '',
      supplier: map['supplier'] ?? '',
      batchNumber: map['batch_number'],
      qrCode: map['qr_code'],
      merk: map['merk'],
    );
  }

  static ItemCategory _mapStringToCategory(String category) {
    switch (category.toLowerCase()) {
      case 'obat': return ItemCategory.obat;
      case 'alat_medis': return ItemCategory.alatMedis;
      case 'bhp': return ItemCategory.bahanHabisPakai;
      case 'apd': return ItemCategory.apd;
      case 'laboratorium': return ItemCategory.laboratorium;
      case 'radiologi': return ItemCategory.radiologi;
      case 'atk': return ItemCategory.atk;
      case 'elektronik': return ItemCategory.elektronik;
      case 'furniture': return ItemCategory.furniture;
      default: return ItemCategory.obat;
    }
  }

  String get categoryName {
    switch (category) {
      case ItemCategory.obat: return 'Obat';
      case ItemCategory.alatMedis: return 'Alat Medis';
      case ItemCategory.bahanHabisPakai: return 'Bahan Habis Pakai';
      case ItemCategory.apd: return 'APD';
      case ItemCategory.laboratorium: return 'Laboratorium';
      case ItemCategory.radiologi: return 'Radiologi';
      case ItemCategory.atk: return 'ATK';
      case ItemCategory.elektronik: return 'Elektronik';
      case ItemCategory.furniture: return 'Furniture';
    }
  }
}
