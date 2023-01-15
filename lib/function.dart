// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

fetchdata(String url) async {
  http.Response response = await http.get(Uri.parse(url));
  return response.body;
}

class StateManagerUpload {
  final progressNotifier = ValueNotifier<double?>(0);
  void lol(String path) async {
    progressNotifier.value = 0;

    const String url = "https://FlutterApp.dabaap.repl.co/";
    final request = http.MultipartRequest('POST', Uri.parse(url));
    // final headers = {"Content-type": "multipart/form-data"};
    var multipartFile = await http.MultipartFile.fromPath('audio', path,
        contentType: MediaType.parse('audio/mp3'));
    request.files.add(multipartFile);

    // request.headers.addAll(headers);
    var response = await request.send();
    // var byteStream = response.stream;
    var totalBytes = response.contentLength;
    var bytesTransferred = 0;

    response.stream.listen((event) {
      bytesTransferred += event.length;
      progressNotifier.value = (bytesTransferred / totalBytes!);
      print(progressNotifier.value);
    });
  }
}

class StateManager {
  final progressNotifier = ValueNotifier<double?>(0);

  void startDownloading() async {
    progressNotifier.value = null;
    late http.StreamedResponse? response;
    const url = 'https://FlutterApp.dabaap.repl.co/demo';
    final request = http.Request('GET', Uri.parse(url));
    try {
      response = await http.Client().send(request);
    } catch (e) {
      return;
    }

    final contentLength = response.contentLength;
    // final contentLength = double.parse(response.headers['x-decompressed-content-length']);

    progressNotifier.value = 0;

    List<int> bytes = [];

    final file = await _getFile('Demo.mp3');

    response.stream.listen(
      (List<int> newBytes) {
        bytes.addAll(newBytes);
        final downloadedLength = bytes.length;
        progressNotifier.value = downloadedLength / contentLength!;
      },
      onDone: () async {
        progressNotifier.value = 1;
        await file.writeAsBytes(bytes);
      },
      onError: (e) {
        debugPrint(e);
      },
      cancelOnError: true,
    );
  }

  Future<File> _getFile(String filename) async {
    Directory? dir = Platform.isAndroid
        ? await getExternalStorageDirectory() //FOR ANDROID
        : await getApplicationSupportDirectory(); //FOR IOS
    return File(join(dir!.path, filename));
  }
}
