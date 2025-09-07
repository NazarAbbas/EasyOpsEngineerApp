import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher_string.dart';

class DocItem {
  final String id;
  final String title;
  final int pages;
  final String url;
  final String fileName;
  DocItem({
    required this.id,
    required this.title,
    required this.pages,
    required this.url,
    required this.fileName,
  });
}

class AssetSpec {
  final String code;
  final String make;
  final String description;
  final String status;
  final String criticality;
  final Map<String, String> technicalData;
  final Map<String, String> commercialData;

  AssetSpec({
    required this.code,
    required this.make,
    required this.description,
    required this.status,
    required this.criticality,
    required this.technicalData,
    required this.commercialData,
  });
}

class AssetSpecificationController extends GetxController {
  final Rx<AssetSpec> asset = Rx<AssetSpec>(_sample());

  final RxList<DocItem> docs = <DocItem>[
    DocItem(
      id: 'catalogue',
      title: 'Catalogue CNC-1',
      pages: 122,
      url:
          'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      fileName: 'catalogue_cnc1',
    ),
    DocItem(
      id: 'training',
      title: 'Training',
      pages: 22,
      url:
          'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      fileName: 'training_cnc1',
    ),
    DocItem(
      id: 'safety',
      title: 'Safety',
      pages: 22,
      url:
          'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      fileName: 'safety_cnc1',
    ),
  ].obs;

  /// 0..1 => progress, -1 => opening, null => idle
  final RxMap<String, double> progress = <String, double>{}.obs;

  Future<void> downloadAndOpen(DocItem doc) async {
    if (progress[doc.id] != null &&
        progress[doc.id]! > 0 &&
        progress[doc.id]! < 1)
      return;

    try {
      final dio = Dio();

      if (kIsWeb) {
        // On web: open URL directly in browser
        await launchUrlString(doc.url, mode: LaunchMode.externalApplication);
        return;
      }

      // Native path
      final savePath = await _getSavePath('${doc.fileName}.pdf');

      if (await File(savePath).exists()) {
        await _openLocal(savePath);
        return;
      }

      progress[doc.id] = 0;
      await dio.download(
        doc.url,
        savePath,
        onReceiveProgress: (r, t) {
          if (t > 0) progress[doc.id] = r / t;
        },
      );

      progress[doc.id] = -1;
      await _openLocal(savePath);
      progress.remove(doc.id);
      Get.snackbar('Downloaded', '${doc.title} saved & opened');
    } catch (e) {
      progress.remove(doc.id);
      Get.snackbar('Download failed', e.toString());
    }
  }

  // -------- Helpers --------
  Future<String> _getSavePath(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$filename';
  }

  Future<void> _openLocal(String path) async {
    final res = await OpenFilex.open(path);
    if (res.type != ResultType.done) {
      Get.snackbar('Open failed', res.message ?? 'Could not open file');
    }
  }

  // -------- Sample seed --------
  static AssetSpec _sample() => AssetSpec(
    code: 'CNC-1',
    make: 'Siemens',
    description: 'CNC Vertical Assets Center where we make housing',
    status: 'Working',
    criticality: 'Critical',
    technicalData: const {
      'Size': '1234',
      'Weight': '1234',
      'Capacity': '1234',
      'Height': '1234',
      'Length': '1234',
      'Width': '1234',
      'Power': '1234',
      'Electricity Consumption': '1234',
    },
    commercialData: const {
      'Manufacturer': '1234',
      'Make': '1234',
      'Model': '1234',
      'Acquisition': '1234',
    },
  );
}
