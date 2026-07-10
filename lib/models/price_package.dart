class PricePackage {
  final String id;
  final String name;        // e.g. 'PS4 Reguler'
  final String psType;      // 'PS4', 'PS5'
  final String tier;        // 'reguler', 'vip'
  final List<PriceTier> prices;  // list of duration-price pairs
  final bool isHighlighted;

  const PricePackage({
    required this.id,
    required this.name,
    required this.psType,
    this.tier = 'reguler',
    required this.prices,
    this.isHighlighted = false,
  });
}

class PriceTier {
  final String duration;
  final int price;

  const PriceTier({
    required this.duration,
    required this.price,
  });
}
