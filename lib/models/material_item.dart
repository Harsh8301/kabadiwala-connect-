class ValueTip {
  const ValueTip({required this.title, required this.description});

  final Map<String, String> title;
  final Map<String, String> description;

  String titleFor(String language) => title[language] ?? title['en']!;
  String descriptionFor(String language) =>
      description[language] ?? description['en']!;
}

class MaterialItem {
  const MaterialItem({
    required this.id,
    required this.icon,
    required this.formalRate,
    required this.informalRate,
    required this.names,
    required this.valueTip,
    this.hazardType,
  });

  final String id;
  final String icon;
  final int formalRate;
  final int informalRate;
  final String? hazardType;
  final Map<String, String> names;
  final ValueTip valueTip;

  bool get isHazardous => hazardType != null;
  String nameFor(String language) => names[language] ?? names['en']!;
}
