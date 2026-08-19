enum UserRole {
  superAdmin,
  kepalaGudang,
  petugasGudang,
  unitPoli,
  direktur
}

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.superAdmin: return 'Super Admin';
      case UserRole.kepalaGudang: return 'Kepala Gudang';
      case UserRole.petugasGudang: return 'Petugas Gudang';
      case UserRole.unitPoli: return 'Unit / Poli';
      case UserRole.direktur: return 'Direktur';
    }
  }

  String get description {
    switch (this) {
      case UserRole.superAdmin: return 'Akses penuh ke seluruh sistem';
      case UserRole.kepalaGudang: return 'Manajer operasional gudang';
      case UserRole.petugasGudang: return 'Pelaksana teknis gudang';
      case UserRole.unitPoli: return 'Pengguna unit layanan';
      case UserRole.direktur: return 'Monitoring & Laporan';
    }
  }
}
