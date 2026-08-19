import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class ReportService {
  Future<void> generateInventoryReport(List<Map<String, dynamic>> items) async {
    final pdf = pw.Document();
    final date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader(date),
          pw.SizedBox(height: 20),
          _buildTable(items),
          pw.SizedBox(height: 40),
          _buildFooter(),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_Inventori_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  pw.Widget _buildHeader(String date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('RSU MUHAMMADIYAH DARUL ISTIQOMAH', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.Text('Jl. Sekopek No. 15, Gladagsari, Plantaran, Kaliwungu, Kendal', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                pw.Text('SIMFAS - Sistem Informasi Fasilitas & Inventori', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
              ],
            ),
            pw.Text('LAPORAN STOK', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.Divider(thickness: 2, color: PdfColors.blue900),
        pw.Text('Dicetak pada: $date', style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  pw.Widget _buildTable(List<Map<String, dynamic>> items) {
    final headers = ['KODE', 'NAMA BARANG', 'STOK', 'SATUAN', 'STATUS'];
    
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: items.map((item) {
        final stock = item['stock'] ?? 0;
        final minStock = item['min_stock'] ?? 0;
        return [
          item['code'] ?? '-',
          item['name'] ?? '-',
          stock.toString(),
          item['unit'] ?? '-',
          stock < minStock ? 'STOK RENDAH' : 'NORMAL',
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
      },
    );
  }

  pw.Widget _buildFooter() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          children: [
            pw.Text('Petugas Gudang Utama,'),
            pw.SizedBox(height: 60),
            pw.Text('( ____________________ )', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('SIMFAS RSDI KENDAL Auto-Generated'),
          ],
        ),
      ],
    );
  }
}
