import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class MultipartService {
  Future<String> submitSubscription({
    File? file,
    String? filename,
  }) async {
    ///MultiPart request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("https://compi.in/api/v1/uploadimage"),
    );
    Map<String, String> headers = {"Content-Type": "multipart/form-data"};
    if (file != null && filename != null) {
      request.files.add(
        http.MultipartFile(
          'image',
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: filename,
          contentType: MediaType('image', 'jpg'),
        ),
      );
    }
    request.headers.addAll(headers);

    var res = await request.send();
    var response = await http.Response.fromStream(res);
    final imageUrl = response.body;
    
    return imageUrl;
  }
}
