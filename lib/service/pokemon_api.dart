import 'dart:convert';
import 'package:flutter_application_1/constants/env.dart';
import 'package:flutter_application_1/models/data/DetailPokemon.dart';
import 'package:flutter_application_1/models/data/Pokemon.dart';
import 'package:http/http.dart' as http;

class PokemonApi {
  static Future<List<Pokemon>> getListPokemon() async {
    try {
      final response = await http.get(Uri.parse(Env.pokeUrl));
      final data = jsonDecode(response.body);
      return (data['results'] as List)
          .map((e) => Pokemon(name: e['name'], url: e['url']))
          .toList();
    } catch (e) {
      throw Exception('Failed to load pokemon: $e');
    }
  }

  static Future<DetailPokemon> getDetailData({required String url}) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final name = data['name'];
        final weight = data['weight'];
        final height = data['height'];
        final img = data['sprites']['front_default'];
        final baseExp = data['base_experience'];
        return DetailPokemon(
            name: name,
            weight: weight,
            height: height,
            img: img,
            baseExp: baseExp);
      } else {
        throw Exception(
            'Failed to load detail pokemon: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load detail pokemon: $e');
    }
  }
}
