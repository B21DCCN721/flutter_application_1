import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/data/DetailPokemon.dart';
import 'package:flutter_application_1/models/data/Pokemon.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.getDetailPokemon,
  });
  final Pokemon pokemon;
  final Future<DetailPokemon> Function(String url) getDetailPokemon;

  void _showBottomSheet(BuildContext context) async {
    final detailPokemon = await getDetailPokemon(pokemon.url);
    if (!context.mounted) return;
    showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    detailPokemon.img,
                  ),
                  Text("Tên: ${detailPokemon.name}"),
                  Text("Cân nặng: ${detailPokemon.weight}"),
                  Text("Chiều cao: ${detailPokemon.height}"),
                  Text("Kinh nghiệm cơ bản: ${detailPokemon.baseExp}")
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              onTap: () => _showBottomSheet(context),
              leading: const Icon(Icons.album),
              title: Text(pokemon.name),
              subtitle: Text('Thông tin chi tiết: ${pokemon.url}'),
            ),
          ],
        ),
      ),
    );
  }
}
