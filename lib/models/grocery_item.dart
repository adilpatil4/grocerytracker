class GroceryItem {
  final String id;
  final String userId;
  final String name;
  final String category;
  final String? brand;
  final String? barcode;
  final int quantity;
  final String unit;
  final DateTime purchaseDate;
  final DateTime? expirationDate;
  final String storageLocation;
  final String? notes;
  final double? purchasePrice;
  final String? storeName;
  final bool isConsumed;
  final DateTime? consumedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroceryItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    this.brand,
    this.barcode,
    required this.quantity,
    required this.unit,
    required this.purchaseDate,
    this.expirationDate,
    required this.storageLocation,
    this.notes,
    this.purchasePrice,
    this.storeName,
    required this.isConsumed,
    this.consumedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      brand: json['brand'] as String?,
      barcode: json['barcode'] as String?,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      purchaseDate: DateTime.parse(json['purchase_date'] as String),
      expirationDate: json['expiration_date'] != null
          ? DateTime.parse(json['expiration_date'] as String)
          : null,
      storageLocation: json['storage_location'] as String,
      notes: json['notes'] as String?,
      purchasePrice: json['purchase_price'] != null
          ? (json['purchase_price'] as num).toDouble()
          : null,
      storeName: json['store_name'] as String?,
      isConsumed: json['is_consumed'] as bool,
      consumedAt: json['consumed_at'] != null
          ? DateTime.parse(json['consumed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category,
      'brand': brand,
      'barcode': barcode,
      'quantity': quantity,
      'unit': unit,
      'purchase_date': purchaseDate.toIso8601String().split('T')[0],
      'expiration_date': expirationDate?.toIso8601String().split('T')[0],
      'storage_location': storageLocation,
      'notes': notes,
      'purchase_price': purchasePrice,
      'store_name': storeName,
      'is_consumed': isConsumed,
      'consumed_at': consumedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GroceryItem copyWith({
    String? name,
    String? category,
    String? brand,
    String? barcode,
    int? quantity,
    String? unit,
    DateTime? purchaseDate,
    DateTime? expirationDate,
    String? storageLocation,
    String? notes,
    double? purchasePrice,
    String? storeName,
    bool? isConsumed,
    DateTime? consumedAt,
  }) {
    return GroceryItem(
      id: id,
      userId: userId,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expirationDate: expirationDate ?? this.expirationDate,
      storageLocation: storageLocation ?? this.storageLocation,
      notes: notes ?? this.notes,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      storeName: storeName ?? this.storeName,
      isConsumed: isConsumed ?? this.isConsumed,
      consumedAt: consumedAt ?? this.consumedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Helper methods for UI
  int get daysUntilExpiration {
    if (expirationDate == null) return -1;
    return expirationDate!.difference(DateTime.now()).inDays;
  }

  bool get isExpired =>
      expirationDate != null && DateTime.now().isAfter(expirationDate!);

  bool get isExpiringSoon =>
      daysUntilExpiration >= 0 && daysUntilExpiration <= 3;

  String get categoryDisplayName {
    switch (category) {
      case 'produce':
        return 'Produce';
      case 'dairy':
        return 'Dairy';
      case 'meat':
        return 'Meat';
      case 'pantry':
        return 'Pantry';
      case 'frozen':
        return 'Frozen';
      case 'beverages':
        return 'Beverages';
      case 'snacks':
        return 'Snacks';
      case 'household':
        return 'Household';
      default:
        return 'Other';
    }
  }

  String get storageDisplayName {
    switch (storageLocation) {
      case 'refrigerator':
        return 'Refrigerator';
      case 'freezer':
        return 'Freezer';
      case 'pantry':
        return 'Pantry';
      case 'cabinet':
        return 'Cabinet';
      case 'counter':
        return 'Counter';
      default:
        return 'Unknown';
    }
  }
}
