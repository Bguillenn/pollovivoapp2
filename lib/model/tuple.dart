class Tuple {
  final String item1;
  final double item2;

  Tuple(this.item1, this.item2);

  Tuple.fromJson(Map<String, dynamic> json)
      : item1 = json["m_Item1"],
        item2 = json["m_Item2"].toDouble();
}
