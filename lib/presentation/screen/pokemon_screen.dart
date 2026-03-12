import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/data/DetailPokemon.dart';
import 'package:flutter_application_1/models/data/Pokemon.dart';
import 'package:flutter_application_1/service/pokemon_api.dart';
import 'package:flutter_application_1/widgets/error.dart';
import 'package:flutter_application_1/widgets/pokemon_card.dart';

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  List<Pokemon>? _allPokemon;
  List<Pokemon>? _pokemon;
  final TextEditingController searchText = TextEditingController();
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _getDataPokemon();
  }

  Future<void> _getDataPokemon() async {
    try {
      final res = await PokemonApi.getListPokemon();
      setState(() {
        _allPokemon = res;
        _pokemon = res;
      });
    } catch (e) {
      print(e);
      setState(() {
        _error = true;
      });
    }
  }

  Future<DetailPokemon> _getDataDetailPokemon(String url) async {
    try {
      final res = await PokemonApi.getDetailData(url: url);
      return res;
    } catch (e) {
      print(e);
      throw Exception('Failed to load detail pokemon: $e');
    }
  }

  void _handleSearch() {
    final search = searchText.text;
    if (_allPokemon != null) {
      final filteredPokemon = _allPokemon!.where((pokemon) {
        return pokemon.name.toLowerCase().contains(search.toLowerCase());
      }).toList();
      setState(() {
        _pokemon = filteredPokemon;
      });
    } else {
      setState(() {
        _pokemon = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pokemon'),
          automaticallyImplyLeading: false,
        ),
        body: _error
            ? const Error()
            : _pokemon == null
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: searchText,
                          onChanged: (value) => _handleSearch(),
                          decoration: const InputDecoration(
                            hintText: 'Tìm kiếm',
                            suffixIcon: Icon(Icons.search),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _pokemon!.length,
                            itemBuilder: (context, index) {
                              return PokemonCard(
                                pokemon: _pokemon![index],
                                getDetailPokemon: _getDataDetailPokemon,
                              );
                            },
                          ),
                        )
                      ],
                    )));
  }
}
