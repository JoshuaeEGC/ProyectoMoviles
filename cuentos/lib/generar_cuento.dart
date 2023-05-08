import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:translator/translator.dart';
import 'dall-e.dart';
import 'gpt.dart';

class Generar_Cuento extends StatefulWidget {
  const Generar_Cuento({super.key});

  @override
  State<Generar_Cuento> createState() => _Generar_CuentoState();
}

class _Generar_CuentoState extends State<Generar_Cuento> {
  final _formKey = GlobalKey<FormState>();
  late int _age;
  late String _genre;
  late String _keywords;
  String _story = '';
  String _imageUrl = '';
  Future SaveToDatabase() async {
    try {
      Map<String, dynamic> data = {};
      var dbTimeKey = DateTime.now();
      var formatDate = DateFormat('MMM dd, yyyy');
      var formatTime = DateFormat('EEEE, hh:mm aaa');

      String date = formatDate.format(dbTimeKey);
      String time = formatTime.format(dbTimeKey);

      data = {
        "image": _imageUrl,
        "story": _story,
        'date': date,
        'time': time,
      };
      await FirebaseFirestore.instance.collection('cuentos').add(data);
    } catch (e) {
      print("Error al subir");
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    try {
      String story = await generateStory(_age, _genre, _keywords);
      String imageUrl = await generateImage(_keywords);
      setState(() {
        _story = story;
        _imageUrl = imageUrl;
      });
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(error.toString()),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Edad del niño'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, ingrese la edad del niño.';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 0) {
                    return 'Por favor, ingrese una edad válida.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _age = int.parse(value!);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Género literario'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, ingrese el género literario.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _genre = value!;
                },
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Palabras clave del cuento'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, ingrese las palabras clave del cuento.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _keywords = value!;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                child: Text('Generar cuento e imagen'),
                onPressed: _submitForm,
              ),
              SizedBox(height: 32),
              if (_story.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Cuento generado:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              if (_story.isNotEmpty)
                Text(
                  _story,
                  style: TextStyle(fontSize: 18),
                ),
              if (_imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Imagen generada:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              if (_imageUrl.isNotEmpty) Image.network(_imageUrl),
              ElevatedButton(
                onPressed: SaveToDatabase,
                child: Text('Guardar cuento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
