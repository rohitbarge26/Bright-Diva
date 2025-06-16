import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

import '../src/cash_management/model/get_cash_receipt_by_id.dart';
import '../src/order_management/model/get_invoice_by_id.dart';
import '../src/order_management/model/get_order_by_id.dart';

class PdfService {
  // Helper function to request storage permissions
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) {
        return true;
      } else {
        var status = await Permission.storage.request();
        if (status.isGranted) {
          return true;
        } else {
          // For Android 11+, request MANAGE_EXTERNAL_STORAGE if needed
          if (await Permission.manageExternalStorage.isGranted) {
            return true;
          } else {
            var manageStatus = await Permission.manageExternalStorage.request();
            return manageStatus.isGranted;
          }
        }
      }
    } else {
      // For iOS, only request storage permission
      var status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  // Helper function to get the Downloads directory path
  static Future<String> _getDownloadsDirectoryPath() async {
    if (Platform.isAndroid) {
      // For Android, use the Downloads directory
      List<Directory>? directories = await getExternalStorageDirectories(type: StorageDirectory.documents);

      if (directories != null && directories.isNotEmpty) {
        Directory documentsDir = directories.first;
        String customPath = "${documentsDir.path}/KFT/Print";
        Directory(customPath).createSync(recursive: true);

        return customPath;
      } else {
        throw Exception("Documents directory not found");
      }
    } else {
      // For iOS, use the Documents directory
      Directory directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  // Generate and save Order PDF
  static Future<File> generateOrderPdf(Order order) async {
    final pdf = pw.Document();
    double amountInHkd = double.parse(order.amountInHkd!);
    double amountOfDelivery = double.parse(order.amountOfDelivery!);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Korean-fashion International Trading Limited',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Address: ${order.customer?.address ?? "N/A"}'),
              pw.Text('Phone: ${order.customer?.mobileNumber ?? "N/A"}'),
              pw.Text('Date: ${order.createdAt ?? "N/A"}'),
              pw.Text(
                  'Business Registration#: ${order.customer?.businessRegistrationNumber ?? "N/A"}'),
              pw.Text('Invoice#: ${order.invoiceNumber ?? "N/A"}'),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('CLIENT'),
                      pw.Text('NOTE'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text(order.customer?.companyName ?? "N/A"),
                      pw.Text(''),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('DATE'),
                      pw.Text('DESCRIPTION'),
                      pw.Text('QTY.'),
                      pw.Text('UNIT PRICE'),
                      pw.Text('TOTAL HKD'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text(order.createdAt ?? "N/A"),
                      pw.Text('Service Charge'),
                      pw.Text('1'),
                      pw.Text('${amountOfDelivery.round()}'),
                      pw.Text('${amountInHkd.round()}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                  'Unless otherwise agreed, all invoices are payable within 10 days by wire transfer to our bank account'),
              pw.Text('SUB TOTAL: ${amountInHkd.round()}'),
              pw.Text('DISCOUNT: -'),
              pw.Text('Amount due HKD: ${amountInHkd.round()}'),
            ],
          );
        },
      ),
    );

    /*// Request storage permissions
    if (!await _requestStoragePermission()) {
      throw Exception("Storage permission denied");
    }*/

    // Get the Downloads directory path
    String downloadsPath = await _getDownloadsDirectoryPath();
    Directory documentsFolder = Directory(downloadsPath);

    // Create the folder if it doesn't exist
    if (!await documentsFolder.exists()) {
      await documentsFolder.create(recursive: true);
    }

    // Define the file path
    final file = File(join(
        documentsFolder.path, 'Order_${order.customer?.companyName}.pdf'));

    // Write the PDF bytes to the file
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Generate and save Invoice PDF
  static Future<File> generateInvoicePdf(InvoiceDetails order) async {
    final pdf = pw.Document();
    double amountInHkd = 0.0;
    if (order.amountInHkd != null && order.amountInHkd!.isNotEmpty) {
      amountInHkd = double.parse(order.amountInHkd!);
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Korean-fashion International Trading Limited',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Address: ${order.customer?.address ?? "N/A"}'),
              pw.Text('Phone: ${order.customer?.mobileNumber ?? "N/A"}'),
              pw.Text('Date: ${order.createdAt ?? "N/A"}'),
              pw.Text(
                  'Business Registration#: ${order.customer?.businessRegistrationNumber ?? "N/A"}'),
              pw.Text('Invoice#: ${order.invoiceNumber ?? "N/A"}'),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('CLIENT'),
                      pw.Text('NOTE'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text(order.customer?.companyName ?? "N/A"),
                      pw.Text(''),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('DATE'),
                      pw.Text('DESCRIPTION'),
                      pw.Text('QTY.'),
                      pw.Text('UNIT PRICE'),
                      pw.Text('TOTAL HKD'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text(order.createdAt ?? "N/A"),
                      pw.Text('Service Charge'),
                      pw.Text('1'),
                      pw.Text('${amountInHkd.round()}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                  'Unless otherwise agreed, all invoices are payable within 10 days by wire transfer to our bank account'),
              pw.Text('SUB TOTAL: ${amountInHkd.round()}'),
              pw.Text('DISCOUNT: -'),
              pw.Text('Amount due HKD: ${amountInHkd.round()}'),
            ],
          );
        },
      ),
    );

    /*// Request storage permissions
    if (!await _requestStoragePermission()) {
      throw Exception("Storage permission denied");
    }
*/
    // Get the Downloads directory path
    String downloadsPath = await _getDownloadsDirectoryPath();
    Directory documentsFolder = Directory(downloadsPath);

    // Create the folder if it doesn't exist
    if (!await documentsFolder.exists()) {
      await documentsFolder.create(recursive: true);
    }

    // Define the file path
    final file = File(join(
        documentsFolder.path, 'Invoice_${order.customer?.companyName}.pdf'));
    print('File location : ${file.path}');
    // Write the PDF bytes to the file
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Generate and save Cash Receipt PDF
  static Future<File> generateCashReceiptPdf(
      CashReceiptDetails cashReceiptData) async {
    final pdf = pw.Document();
    double amountInHkd = 0.0;
    if (cashReceiptData.amountInHkd != null &&
        cashReceiptData.amountInHkd!.isNotEmpty) {
      amountInHkd = double.parse(cashReceiptData.amountInHkd!);
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Korean-Fashion International Trading Limited',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Address: ${cashReceiptData.customer?.address ?? "N/A"}'),
              pw.Text(
                  'Phone: ${cashReceiptData.customer?.mobileNumber ?? "N/A"}'),
              pw.Text('Date: ${cashReceiptData.createdAt ?? "N/A"}'),
              pw.Text(
                  'Business Registration#: ${cashReceiptData.customer?.businessRegistrationNumber ?? "N/A"}'),
              pw.Text('Invoice#: ${cashReceiptData.invoiceNumber ?? "N/A"}'),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('CLIENT'),
                      pw.Text('NOTE'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text(cashReceiptData.customer?.companyName ?? "N/A"),
                      pw.Text(''),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('DATE'),
                      pw.Text('DESCRIPTION'),
                      pw.Text('QTY.'),
                      pw.Text('UNIT PRICE'),
                      pw.Text('TOTAL HKD'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text(cashReceiptData.createdAt ?? "N/A"),
                      pw.Text('Service Charge'),
                      pw.Text('1'),
                      pw.Text('${amountInHkd.round()}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                  'Unless otherwise agreed, all invoices are payable within 10 days by wire transfer to our bank account'),
              pw.Text('SUB TOTAL: ${amountInHkd.round()}'),
              pw.Text('DISCOUNT: -'),
              pw.Text('Amount due HKD: ${amountInHkd.round()}'),
            ],
          );
        },
      ),
    );

    // Request storage permissions
    if (!await _requestStoragePermission()) {
      throw Exception("Storage permission denied");
    }

    // Get the Downloads directory path
    String downloadsPath = await _getDownloadsDirectoryPath();
    Directory documentsFolder = Directory(downloadsPath);

    // Create the folder if it doesn't exist
    if (!await documentsFolder.exists()) {
      await documentsFolder.create(recursive: true);
    }

    // Define the file path
    final file = File(join(documentsFolder.path,
        'Cash Receipt_${cashReceiptData.customer?.companyName}.pdf'));

    // Write the PDF bytes to the file
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}