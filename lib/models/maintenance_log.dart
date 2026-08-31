enum MaintenanceStatus { pending, perbaikan, selesai, rusakTotal }
enum DamageLevel { ringan, sedang, berat }

class MaintenanceLog {
  final String id;
  final String itemId;
  final String itemName;
  final String reporterName;
  final String description;
  final DamageLevel damageLevel;
  final MaintenanceStatus status;
  final double cost;
  final DateTime createdAt;
  final DateTime? fixedAt;
  
  // Fitur Baru Rekomendasi
  final String? photoUrl;
  final String? location;
  final String? assignedToId;
  final String? assignedToName;
  final DateTime? estimatedFinish;
  final List<dynamic>? auditLog;

  MaintenanceLog({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.reporterName,
    required this.description,
    required this.damageLevel,
    required this.status,
    required this.cost,
    required this.createdAt,
    this.fixedAt,
    this.photoUrl,
    this.location,
    this.assignedToId,
    this.assignedToName,
    this.estimatedFinish,
    this.auditLog,
  });

  factory MaintenanceLog.fromMap(Map<String, dynamic> map) {
    return MaintenanceLog(
      id: map['id'],
      itemId: map['item_id'].toString(),
      itemName: map['items']?['name'] ?? 'Barang Tanpa Nama',
      reporterName: map['profiles']?['full_name'] ?? 'Anonim',
      description: map['description'] ?? '',
      damageLevel: _parseDamageLevel(map['damage_level']),
      status: _parseStatus(map['status']),
      cost: (map['cost'] ?? 0).toDouble(),
      createdAt: DateTime.parse(map['created_at']),
      fixedAt: map['fixed_at'] != null ? DateTime.parse(map['fixed_at']) : null,
      
      // Parsing Fitur Baru
      photoUrl: map['photo_url'],
      location: map['location'],
      assignedToId: map['assigned_to'],
      assignedToName: map['assignee']?['full_name'], // Asumsi join profile assignee
      estimatedFinish: map['estimated_finish'] != null ? DateTime.parse(map['estimated_finish']) : null,
      auditLog: map['audit_log'],
    );
  }

  static DamageLevel _parseDamageLevel(String? level) {
    switch (level) {
      case 'sedang': return DamageLevel.sedang;
      case 'berat': return DamageLevel.berat;
      default: return DamageLevel.ringan;
    }
  }

  static MaintenanceStatus _parseStatus(String? status) {
    switch (status) {
      case 'perbaikan': return MaintenanceStatus.perbaikan;
      case 'selesai': return MaintenanceStatus.selesai;
      case 'rusak_total': return MaintenanceStatus.rusakTotal;
      default: return MaintenanceStatus.pending;
    }
  }
}
