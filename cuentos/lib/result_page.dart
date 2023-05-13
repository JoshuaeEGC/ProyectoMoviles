import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResultPage extends StatelessWidget {
  final String story;
  final String imageUrl;

  ResultPage({Key? key, required this.story, required this.imageUrl})
      : super(key: key);

  Future<void> _saveToDatabase(BuildContext context) async {
    String? title = await showDialog<String>(
      context: context,
      builder: (context) => _SaveDialog(),
    );

    if (title != null && title.isNotEmpty) {
      try {
        GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          // Usuario no autenticado
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo obtener el usuario actual')),
          );
          return;
        }

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(
            idToken: (await googleUser.authentication).idToken,
            accessToken: (await googleUser.authentication).accessToken,
          ),
        );

        User? user = userCredential.user;
        if (user == null) {
          // Usuario no autenticado
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo obtener el usuario actual')),
          );
          return;
        }

        Map<String, dynamic> data = {};
        var dbTimeKey = DateTime.now();
        var formatDate = DateFormat('MMM dd, yyyy');
        var formatTime = DateFormat('EEEE, hh:mm aaa');

        String date = formatDate.format(dbTimeKey);
        String time = formatTime.format(dbTimeKey);

        data = {
          "titulo": title,
          "image": imageUrl,
          "story": story,
          'date': date,
          'time': time,
          'userId': user.uid, // Agregar el UID del usuario a base de datos
        };
        await FirebaseFirestore.instance.collection('cuentos').add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cuento guardado correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el cuento')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(159, 6, 255, 164),
        title: Text('Resultado'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (story.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Cuento generado:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            if (story.isNotEmpty)
              Text(
                story,
                style: TextStyle(fontSize: 18),
              ),
            if (imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Imagen generada:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            if (story.isNotEmpty && imageUrl.isNotEmpty)
              if (imageUrl.isNotEmpty) Image.network(imageUrl),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(159, 6, 255, 164),
                onPrimary: Colors.white,
              ),
              onPressed: () => _saveToDatabase(context),
              child: Text('Guardar cuento'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(159, 6, 255, 164),
                onPrimary: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveDialog extends StatefulWidget {
  @override
  _SaveDialogState createState() => _SaveDialogState();
}

class _SaveDialogState extends State<_SaveDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Guardar cuento'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Título'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Por favor, ingrese un título.';
                }
                return null;
              },
              onSaved: (value) {
                _title = value!;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('Guardar'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Navigator.of(context).pop(_title);
            }
          },
        ),
      ],
    );
  }
}
