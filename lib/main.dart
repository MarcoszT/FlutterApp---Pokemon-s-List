import 'package:flutter/material.dart';
import 'package:todolist_flutter/screens/pokelist_screen.dart';
import 'package:todolist_flutter/theme/app_theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      theme: AppTheme().theme(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lista de Pokemons'),
          elevation: 0,
        ),
        body: PokemonList(),
      ),
    );
  }
}
