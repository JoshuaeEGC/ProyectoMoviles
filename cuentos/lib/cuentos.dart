import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Cuentos extends StatefulWidget {
  const Cuentos({super.key});

  @override
  State<Cuentos> createState() => _CuentosState();
}

class _CuentosState extends State<Cuentos> {
  final Stream<QuerySnapshot> cuentos =
      FirebaseFirestore.instance.collection('cuentos').snapshots();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: cuentos,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Algo salio mal');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Cargando");
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            return ListTile(
              title: Text(data['story']),
              subtitle: Image.network(data['image']),
            );
          }).toList(),
        );
      },
    );
  }
}
