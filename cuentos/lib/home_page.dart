import 'package:flutter/material.dart';

import 'dall-e.dart';
import 'gpt.dart';

class home_page extends StatefulWidget {
  const home_page({
    super.key,
  });

  @override
  State<home_page> createState() => _home_pageState();
}

class _home_pageState extends State<home_page> {
  final _formKey = GlobalKey<FormState>();
  int _currentIndex = 0;

  final _pagesName = ["Generar", "Cuentos", "Perfil"];

  late int _age;
  late String _genre;
  late String _keywords;
  String _story = '';
  String _imageUrl = '';

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
      appBar: AppBar(
        title: Text('Generador de cuentos'),
      ),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        destinations: _bottomDestinations,
      ),
    );
  }

  List<Widget> get _bottomDestinations {
    return [
      NavigationDestination(
        icon: Icon(Icons.book),
        label: '${_pagesName[0]}',
      ),
      NavigationDestination(
        icon: Icon(Icons.list),
        label: '${_pagesName[1]}',
      ),
      NavigationDestination(
        icon: Icon(Icons.person),
        label: '${_pagesName[2]}',
      ),
    ];
  }
}
