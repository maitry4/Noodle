// ignore: dangling_library_doc_comments
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class BackendService {
  Future<String> processAudio(String audioPath) async {
    final uri = Uri.parse('http://192.168.150.11:8000/noodle');

    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath(
        'audio',
        audioPath,
        contentType: MediaType('audio', 'pcm'),
      ),
    );
    print("Sending audio: $audioPath");
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Backend error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    return json['text'] ?? 'No response';
  }
}
