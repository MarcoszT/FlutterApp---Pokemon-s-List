import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonList extends StatefulWidget {
  @override
  _PokemonListState createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  List<Map<String, dynamic>> pokemonList = [];
  List<Map<String, dynamic>> filteredPokemonList = [];
  int offset = 0;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final Uri url =
        Uri.parse('https://pokeapi.co/api/v2/pokemon/?offset=$offset&limit=20');
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<Map<String, dynamic>> tempList = [];

      for (var pokemon in data['results']) {
        var pokemonInfo = await http.get(Uri.parse(pokemon['url']));
        if (pokemonInfo.statusCode == 200) {
          var pokemonData = json.decode(pokemonInfo.body);
          tempList.add({
            'number': pokemonData['id'],
            'name': pokemon['name'],
            'imageUrl': pokemonData['sprites']['front_default'],
            'types': pokemonData['types'].map((type) => type['type']['name']).toList(),
          });
        } else {
          throw Exception('Error al cargar los datos de un Pokémon');
        }
      }

      setState(() {
        pokemonList.addAll(tempList);
        filteredPokemonList = List.from(pokemonList);
        offset += 20;
      });
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Pokémon por nombre',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      filteredPokemonList.clear();
                      filteredPokemonList.addAll(pokemonList);
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  filteredPokemonList = pokemonList
                      .where((pokemon) =>
                          pokemon['name']
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: filteredPokemonList.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '# ${filteredPokemonList[index]['number']}', 
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Image.network(
                        filteredPokemonList[index]['imageUrl'],
                        width: 100.0,
                        height: 100.0,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        filteredPokemonList[index]['name'],
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        '${filteredPokemonList[index]['types'].join(', ')}', 
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fetchData();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
