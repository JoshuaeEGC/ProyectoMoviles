import 'package:cuentos/result_page.dart';
import 'package:flutter/material.dart';

import 'dall-e.dart';
import 'gpt.dart';

class GenerarCuento extends StatefulWidget {
  const GenerarCuento({Key? key});

  @override
  State<GenerarCuento> createState() => _GenerarCuentoState();
}

class _GenerarCuentoState extends State<GenerarCuento> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedAge;
  String? _selectedGenre;
  late String _keywords;
  String _story = '';
  String _imageUrl = '';
  bool _isLoading = false;

  List<int> _ageOptions = List.generate(16, (index) => index);
  List<String> _genreOptions = [
    'Fantasía',
    'Terror',
    'Aventura',
    'Ciencia ficción'
  ];

  Future<void> _generateStoryAndImage() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      String story =
          await generateStory(_selectedAge!, _selectedGenre!, _keywords);
      String imageUrl = await generateImage(_keywords);
      setState(() {
        _story = story;
        _imageUrl = imageUrl;
        _selectedAge = null; // Restablecer la edad a vacío
        _selectedGenre = null; // Restablecer el género literario a vacío
      });
      _formKey.currentState!.reset(); // Restablecer los campos del formulario
      _navigateToResultPage();
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToResultPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultPage(story: _story, imageUrl: _imageUrl),
      ),
    );
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
              DropdownButtonFormField<int>(
                value: _selectedAge,
                decoration: InputDecoration(labelText: 'Edad del niño'),
                items: _ageOptions.map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, seleccione la edad del niño.';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _selectedAge = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedGenre,
                decoration: InputDecoration(labelText: 'Género literario'),
                items: _genreOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, seleccione el género literario.';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _selectedGenre = value;
                  });
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
              _isLoading
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary:
                            Color.fromARGB(159, 6, 255, 164), // COlor del boton
                        onPrimary: Colors.white, // color de texto
                      ),
                      child: Text('Generar cuento e imagen'),
                      onPressed: _generateStoryAndImage,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
