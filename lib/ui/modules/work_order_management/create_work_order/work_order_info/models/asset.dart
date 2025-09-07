class Asset {
  final String number;
  final String type;
  final String description;
  const Asset(this.number, this.type, this.description);
}

class AssetsCatalog {
  // In-memory catalog (sample data — replace with real values)
  static const List<Asset> items = [
    Asset('1001', 'High', '3-phase, 2HP induction motor'),
    Asset('1002', 'Critical', 'Coolant pump, 1.5kW, SS impeller'),
    Asset('1003', 'Medium', '24V DC cooling fan, 120mm'),
    Asset('1004', 'Low', 'Belt conveyor, 1m, variable speed'),
  ];

  // Quick index for lookups by number (case-insensitive)
  static final Map<String, Asset> index = {
    for (final a in items) a.number.toUpperCase(): a,
  };

  static Asset? find(String number) => index[number.trim().toUpperCase()];
}
