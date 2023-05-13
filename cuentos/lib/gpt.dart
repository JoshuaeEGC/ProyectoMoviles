import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> generateStory(int age, String genre, String keywords) async {
  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/completions'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer APIKEY',
    },
    encoding: utf8,
    body: jsonEncode({
      "model": "text-davinci-003",
      'prompt':
          'Generar un cuento para un niño de $age años de edad de genero literario $genre sobre estos temas $keywords. El cuento damelo sin acentos, no importa si en gramatica esta mal, no quiero acentos, ni tampoco ñ en caso de salir ñ cambiar por n, recuerda cumplir todo lo requerido',
      'temperature': 1,
      'max_tokens': 1000,
    }),
  );

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    return responseBody['choices'][0]['text'];
  } else {
    throw 'Ha ocurrido un error al generar el cuento.';
  }
}
