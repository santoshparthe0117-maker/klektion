import 'dart:io';
import 'package:csv/csv.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExportController extends GetxController {
  final supabase = Supabase.instance.client;

  /// 🔍 Fetch all collections + items for this user
  Future<List<Map<String, dynamic>>> fetchCollectionsWithItems() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final collections = await supabase
        .from("collections")
        .select("*, items(*)")
        .eq("user_id", userId);

    return List<Map<String, dynamic>>.from(collections);
  }

  /// 📁 Get device path for saving files
  Future<String> _getSavePath(String filename) async {
    Directory dir;

    if (Platform.isAndroid) {
      await Permission.storage.request();
      dir = (await getExternalStorageDirectory())!;
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final path = "${dir.path}/$filename";
    return path;
  }

  /// 🔽 Save CSV file
  Future<String> exportCSV() async {
    final data = await fetchCollectionsWithItems();

    List<List<dynamic>> rows = [
      [
        "Collection Name",
        "Description",
        "Item Name",
        "Purchase Price",
        "Value",
      ],
    ];

    for (var col in data) {
      final items = col["items"] as List<dynamic>;

      for (var item in items) {
        rows.add([
          col["name"],
          col["description"] ?? "",
          item["name"],
          item["purchase_price"] ?? "",
          item["estimated_value"] ?? "",
        ]);
      }
    }

    String csvData = const ListToCsvConverter().convert(rows);

    final path = await _getSavePath("collections_export.csv");
    final file = File(path);
    await file.writeAsString(csvData);

    OpenFilex.open(path);

    return path;
  }

  /// 📄 Export PDF file
  Future<String> exportPDF() async {
    final data = await fetchCollectionsWithItems();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 1, text: "Collection Export"),
          ...data.map(
            (col) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  col["name"] ?? "",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(col["description"] ?? ""),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: ["Item Name", "Purchase Price", "Value"],
                  data: (col["items"] as List<dynamic>)
                      .map(
                        (item) => [
                          item["name"],
                          item["purchase_price"].toString(),
                          item["estimated_value"].toString(),
                        ],
                      )
                      .toList(),
                ),
                pw.Divider(),
              ],
            ),
          ),
        ],
      ),
    );

    final path = await _getSavePath("collections_export.pdf");
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    OpenFilex.open(path);

    return path;
  }
}
