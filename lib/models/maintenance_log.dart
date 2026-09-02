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
    // Helper untuk mengambil data dari join (antisipasi jika Supabase mengembalikan List atau Object)
    String? getJoinField(dynamic joinData, String field) {
      if (joinData == null) return null;
      if (joinData is List && joinData.isNotEmpty) {
        return joinData[0][field]?.toString();
      }
      if (joinData is Map) {
        return joinData[field]?.toString();
      }
      return null;
    }

    return MaintenanceLog(
      id: map['id']?.toString() ?? '',
      itemId: map['item_id']?.toString() ?? '',
      itemName: getJoinField(map['items'], 'name') ?? 'Barang Tanpa Nama',
      reporterName: getJoinField(map['profiles'], 'full_name') ?? 'Anonim',
      description: map['description']?.toString() ?? '',
      damageLevel: _parseDamageLevel(map['damage_level']?.toString()),
      status: _parseStatus(map['status']?.toString()),
      cost: double.tryParse(map['cost']?.toString() ?? '0.0') ?? 0.0,
      createdAt: map['created_at'] != null 
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      fixedAt: map['fixed_at'] != null ? DateTime.tryParse(map['fixed_at'].toString()) : null,
      
      // Parsing Fitur Baru
      photoUrl: map['photo_url']?.toString(),
      location: map['location']?.toString(),
      assignedToId: map['assigned_to']?.toString(),
      assignedToName: getJoinField(map['assignee'], 'full_name'),
      estimatedFinish: map['estimated_finish'] != null 
          ? DateTime.tryParse(map['estimated_finish'].toString()) 
          : null,
      auditLog: map['audit_log'] is List ? map['audit_log'] : [],
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
