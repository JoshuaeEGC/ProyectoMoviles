import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> generateStory(int age, String genre, String keywords) async {
  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/completions'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer APITOKEN',
    },
    encoding: utf8,
    body: jsonEncode({
      "model": "text-davinci-003",
      'prompt':
          'Generar un cuento de $age años de edad en el género $genre con las palabras clave $keywords.',
      'temperature': 1,
      'max_tokens': 500,
    }),
  );

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    return responseBody['choices'][0]['text'];
  } else {
    throw 'Ha ocurrido un error al generar el cuento.';
  }
}
