/// プレイヤー情報を表すモデル
class Player {
  final String id;
  final String name;
  final String theme;
  final bool isWolf;
  final int? votedForIndex;

  const Player({
    required this.id,
    required this.name,
    required this.theme,
    required this.isWolf,
    this.votedForIndex,
  });

  Player copyWith({
    String? id,
    String? name,
    String? theme,
    bool? isWolf,
    int? votedForIndex,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      theme: theme ?? this.theme,
      isWolf: isWolf ?? this.isWolf,
      votedForIndex: votedForIndex ?? this.votedForIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'theme': theme,
        'isWolf': isWolf,
        'votedForIndex': votedForIndex,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        name: json['name'] as String,
        theme: json['theme'] as String,
        isWolf: json['isWolf'] as bool,
        votedForIndex: json['votedForIndex'] as int?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          theme == other.theme &&
          isWolf == other.isWolf &&
          votedForIndex == other.votedForIndex;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      theme.hashCode ^
      isWolf.hashCode ^
      votedForIndex.hashCode;
}
