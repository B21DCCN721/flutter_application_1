class DetailPokemon {
  final String name;
  final int weight;
  final int height;
  final String img;
  final int baseExp;

  DetailPokemon({
    required this.name,
    required this.weight,
    required this.height,
    required this.img,
    required this.baseExp,
  });
  static DetailPokemon fromJson(Map<String, dynamic> json) {
    return DetailPokemon(
      name: json['name'],
      weight: json['weight'],
      height: json['height'],
      img: json['sprites']['front_default'],
      baseExp: json['base_experience'],
    );
  }
}
