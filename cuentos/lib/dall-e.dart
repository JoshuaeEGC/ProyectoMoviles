import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> generateImage(String keywords) async {
  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/images/generations'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer APIKEY',
    },
    body: jsonEncode({
      'model': 'image-alpha-001',
      'prompt':
          'Generar una imagen para un cuento de un niño basada en las palabras clave $keywords. La imagen no debe tener texto',
      'num_images': 1,
    }),
  );

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    return responseBody['data'][0]['url'];
  } else {
    throw 'Ha ocurrido un error al generar la imagen.';
  }
}
