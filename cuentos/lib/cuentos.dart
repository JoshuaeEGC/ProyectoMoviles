import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'package:firebase_auth/firebase_auth.dart';

class Cuentos extends StatefulWidget {
  const Cuentos({Key? key});

  @override
  State<Cuentos> createState() => _CuentosState();
}

class _CuentosState extends State<Cuentos> {
  final Stream<QuerySnapshot> cuentos = FirebaseFirestore.instance
      .collection('cuentos')
      .orderBy('date', descending: true)
      .snapshots();

  String? selectedSortType; // Tipo de ordenamiento seleccionado
  String? selectedSortOrder; // Orden seleccionado
  String searchQuery = ''; // Consulta de búsqueda

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No se pudo obtener la información del usuario.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  void _shareOnWhatsApp(String title, String story) async {
    String content = '$title: $story';
    String url = 'whatsapp://send?text=$content';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No se pudo abrir WhatsApp.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  void _shareOnFacebook(String title, String story) async {
    String content = '$title: $story';
    String url = 'https://www.facebook.com/sharer/sharer.php?u=$content';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No se pudo abrir Facebook.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  void _shareOnTwitter(String title, String story) async {
    String content = '$title: $story';
    String url = 'https://twitter.com/intent/tweet?text=$content';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No se pudo abrir Twitter.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  Future<void> _saveAndSharePDF(String titulo, String story) async {
    final pdf = pw.Document();

    final fontBold =
        pw.Font.ttf(await rootBundle.load("lib/assets/fonts/Roboto-Bold.ttf"));
    final fontRegular = pw.Font.ttf(
        await rootBundle.load("lib/assets/fonts/Roboto-Regular.ttf"));

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                titulo,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  font: fontBold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                story,
                style: pw.TextStyle(
                  font: fontRegular,
                ),
              ),
            ],
          );
        },
      ),
    );
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/cuento.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    OpenFile.open(filePath);
    print('Ruta del archivo PDF: $filePath');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: cuentos,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Algo salió mal');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Cargando");
        }

        List<QueryDocumentSnapshot> sortedList = snapshot.data!.docs;

        sortedList.sort((a, b) {
          if (selectedSortType == 'Fecha') {
            String? dateA = a['date'];
            String? dateB = b['date'];

            if (dateA == null || dateB == null) {
              return 0; // Manejar casos de fecha nula
            }

            DateTime parsedDateA = DateFormat('MMM dd, yyyy').parse(dateA);
            DateTime parsedDateB = DateFormat('MMM dd, yyyy').parse(dateB);
            return parsedDateA.compareTo(parsedDateB);
          } else if (selectedSortType == 'Nombre') {
            String titleA = a['titulo'];
            String titleB = b['titulo'];
            return titleA.compareTo(titleB);
          }

          return 0;
        });

        if (selectedSortOrder == 'Ascendente') {
          sortedList = sortedList.reversed.toList();
        }

        List<QueryDocumentSnapshot> filteredList = sortedList
            .where((document) =>
                document['userId'] == _currentUser.uid &&
                document['titulo']
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
            .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Buscar título',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: selectedSortType,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSortType = newValue;
                    });
                  },
                  items: <String>['Fecha', 'Nombre'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  hint: Text('Ordenar por'),
                ),
                SizedBox(width: 20),
                DropdownButton<String>(
                  value: selectedSortOrder,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSortOrder = newValue;
                    });
                  },
                  items:
                      <String>['Ascendente', 'Descendente'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  hint: Text('Orden'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: filteredList.map((document) {
                  try {
                    return ExpansionTile(
                      title: Text(document['titulo']),
                      subtitle: Text(document['date']),
                      children: [
                        Text(document['story']),
                        Image.network(document['image']),
                        ElevatedButton(
                          onPressed: () {
                            try {
                              _saveAndSharePDF(
                                document['titulo'],
                                document['story'],
                              );
                            } catch (e) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Error'),
                                  content: Text(
                                      'No se pudo guardar el archivo PDF. Error: $e'),
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
                          },
                          child: Text('Guardar como PDF'),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              onPressed: () {
                                _shareOnWhatsApp(
                                  document['titulo'],
                                  document['story'],
                                );
                              },
                              icon: Icon(Icons.share),
                              tooltip: 'Compartir en WhatsApp',
                            ),
                            IconButton(
                              onPressed: () {
                                _shareOnFacebook(
                                  document['titulo'],
                                  document['story'],
                                );
                              },
                              icon: Icon(Icons.facebook),
                              tooltip: 'Compartir en Facebook',
                            ),
                            IconButton(
                              onPressed: () {
                                _shareOnTwitter(
                                  document['titulo'],
                                  document['story'],
                                );
                              },
                              icon: Icon(Icons.share),
                              tooltip: 'Compartir en Twitter',
                            ),
                          ],
                        ),
                      ],
                    );
                  } catch (e) {
                    return ListTile(
                      title: Text('Error al mostrar el cuento'),
                      subtitle: Text('No se pudo recuperar el cuento.'),
                    );
                  }
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
