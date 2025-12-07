/// お題のペア（市民用とウルフ用）
class ThemePair {
  final String id;
  final String category;
  final String majorityTheme;
  final String minorityTheme;
  final bool isCustom;

  const ThemePair({
    required this.id,
    required this.category,
    required this.majorityTheme,
    required this.minorityTheme,
    this.isCustom = false,
  });

  ThemePair copyWith({
    String? id,
    String? category,
    String? majorityTheme,
    String? minorityTheme,
    bool? isCustom,
  }) {
    return ThemePair(
      id: id ?? this.id,
      category: category ?? this.category,
      majorityTheme: majorityTheme ?? this.majorityTheme,
      minorityTheme: minorityTheme ?? this.minorityTheme,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'majorityTheme': majorityTheme,
        'minorityTheme': minorityTheme,
        'isCustom': isCustom,
      };

  factory ThemePair.fromJson(Map<String, dynamic> json) => ThemePair(
        id: json['id'] as String,
        category: json['category'] as String,
        majorityTheme: json['majorityTheme'] as String,
        minorityTheme: json['minorityTheme'] as String,
        isCustom: json['isCustom'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemePair &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          category == other.category &&
          majorityTheme == other.majorityTheme &&
          minorityTheme == other.minorityTheme &&
          isCustom == other.isCustom;

  @override
  int get hashCode =>
      id.hashCode ^
      category.hashCode ^
      majorityTheme.hashCode ^
      minorityTheme.hashCode ^
      isCustom.hashCode;
}
