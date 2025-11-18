import 'dart:io';
import 'package:csv/csv.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExportController extends GetxController {
  final supabase = Supabase.instance.client;

  /// -------------------------------------------------------------------------
  /// 🔍 Fetch ALL ITEMS with collection + category + item details
  /// -------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchItemsData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from("items")
        .select("""
          *,
          categories:category_id(name),
          collections:collection_id(name, description),
          item_images(image_url)
        """)
        .eq("user_id", userId)
        .eq("is_deleted", false)
        .order("created_at", ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// -------------------------------------------------------------------------
  /// 📁 Get save location for PDF/CSV
  /// -------------------------------------------------------------------------
  Future<String> _getSavePath(String filename) async {
    Directory dir;

    if (Platform.isAndroid) {
      await Permission.storage.request();
      dir = (await getExternalStorageDirectory())!;
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    return "${dir.path}/$filename";
  }

  /// -------------------------------------------------------------------------
  /// 📄 Export CSV of FULL item details
  /// -------------------------------------------------------------------------
  Future<String> exportCSV() async {
    final List items = await fetchItemsData();

    List<List<dynamic>> rows = [
      [
        "Item Name",
        "Category",
        "Collection",
        "Collection Description",
        "Description",
        "Condition",
        "Purchase Price",
        "Estimated Value",
        "Acquisition Date",
        "Visibility",
      ],
    ];

    for (var item in items) {
      rows.add([
        item["name"],
        item["categories"]?["name"] ?? "No Category",
        item["collections"]?["name"] ?? "No Collection",
        item["collections"]?["description"] ?? "",
        item["description"] ?? "",
        item["condition"] ?? "",
        item["purchase_price"] ?? "",
        item["estimated_value"] ?? "",
        item["acquisition_date"] ?? "",
        item["visibility"] ?? "",
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final path = await _getSavePath("items_export.csv");

    final file = File(path);
    await file.writeAsString(csvData);

    OpenFilex.open(path);
    return path;
  }

  /// -------------------------------------------------------------------------
  /// 📘 Export PDF of FULL item details
  /// -------------------------------------------------------------------------
  Future<String> exportPDF() async {
    final List items = await fetchItemsData();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (ctx) => [
          // 🔥 Centered App Name
          pw.Center(
            child: pw.Text(
              "Klektion",
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),

          pw.SizedBox(height: 10),

          // 🔥 Section Title
          pw.Center(
            child: pw.Text(
              "Items Export Report",
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),

          pw.SizedBox(height: 20),

          // 🔥 Table
          pw.TableHelper.fromTextArray(
            headers: ["Item", "Category", "Collection", "Purchase", "Value"],
            data: items.map((item) {
              return [
                item["name"] ?? "",
                item["categories"]?["name"] ?? "No Category",
                item["collections"]?["name"] ?? "No Collection",
                "${item["purchase_price"] ?? ""}",
                "${item["estimated_value"] ?? ""}",
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
            cellStyle: pw.TextStyle(fontSize: 11),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFE0E0E0),
            ),
            cellAlignment: pw.Alignment.centerLeft,
            border: pw.TableBorder.all(),
          ),
        ],
      ),
    );

    final path = await _getSavePath("items_export.pdf");
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    OpenFilex.open(path);

    return path;
  }
}
