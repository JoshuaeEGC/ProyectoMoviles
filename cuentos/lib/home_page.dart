import 'package:cuentos/cuentos.dart';
import 'package:cuentos/generar_cuento.dart';
import 'package:cuentos/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth/bloc/auth_bloc.dart';

class home_page extends StatefulWidget {
  const home_page({
    super.key,
  });

  @override
  State<home_page> createState() => _home_pageState();
}

class _home_pageState extends State<home_page> {
  int _currentIndex = 0;
  final _pagesList = [
    GenerarCuento(),
    Cuentos(),
    UserInfoScreen(),
  ];
  final _pagesName = ["Generar", "Cuentos", "Perfil"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(159, 6, 255, 164),
        title: Text('${_pagesName[_currentIndex]}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              BlocProvider.of<AuthBloc>(context).add(SignOutEvent());
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pagesList,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Color.fromARGB(159, 6, 255, 164),
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
