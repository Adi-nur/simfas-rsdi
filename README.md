# SIMFAS RS Umum Darul Istiqomah

**Sistem Manajemen Inventaris Rumah Sakit**

MedInventory Pro adalah sistem manajemen inventaris yang profesional, modern, dan komprehensif yang dirancang untuk operasional rumah sakit. Sistem ini menyederhanakan pelacakan persediaan medis, obat-obatan, dan aset umum rumah sakit.

## Fitur Utama

*   **Dasbor**: Statistik waktu nyata untuk total item, stok rendah, barang kadaluarsa, dan aktivitas terkini.
*   **Manajemen Data Induk**: Basis data terpusat untuk barang (obat-obatan, peralatan medis, APD, dll.), pemasok, dan lokasi penyimpanan.
*   **Manajemen Stok**:
    *   Barang masuk (dari pemasok atau unit lain).
    *   Barang keluar (penggunaan di unit-unit seperti UGD, ICU, dll.).
    *   Mutasi internal (memindahkan barang antar gudang).
    *   Stock Opname (penghitungan inventaris fisik).
*   **Pengadaan & Permintaan**: Alur kerja untuk permintaan pasokan berbasis unit dan proses pengadaan.
*   **Peringatan & Pemberitahuan**: Peringatan otomatis untuk tingkat stok rendah dan tanggal kedaluwarsa yang mendekat.

## Tumpukan Teknologi

*   **Frontend**: Flutter (Mobile & Tablet)
*   **Kerangka Kerja UI**: Material 3
*   **Manajemen Negara**: (Terencana: Penyedia atau Blok)
*   **Antarmuka Backend**: (Rencana: Laravel REST API)

## Memulai
1.  Kloning repositori tersebut.
2.  Jalankan perintah `flutter pub get` untuk menginstal dependensi.
3.  Jalankan aplikasi menggunakan `flutter run`.

## Status Proyek Saat Ini

- [x] Antarmuka Pengguna Dasbor Awal
- [x] Navigasi Data Utama
- [x] Tampilan Daftar Item Inventaris
- [x] Formulir Tambah Item Baru
- [x] Navigasi Manajemen Stok
- [ ] Integrasi API Backend
- [ ] Pemindai Kode Batang/Kode QR
- [ ] Laporan dan Analisis
