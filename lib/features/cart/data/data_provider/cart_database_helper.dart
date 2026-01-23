import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cart_item.dart';

class CartDatabaseHelper {
  static final CartDatabaseHelper _instance = CartDatabaseHelper._internal();
  static Database? _database;

  factory CartDatabaseHelper() {
    return _instance;
  }

  CartDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'commercepal_cart.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId TEXT NOT NULL,
        productName TEXT NOT NULL,
        productImageUrl TEXT,
        quantity INTEGER NOT NULL,
        unitPrice REAL NOT NULL,
        subtotal REAL NOT NULL,
        currency TEXT NOT NULL,
        provider TEXT,
        stockStatus TEXT,
        isAvailable INTEGER NOT NULL,
        priceWhenAdded REAL,
        currentPrice REAL,
        priceDropped INTEGER,
        savingsAmount REAL,
        configId TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add configId column to existing database
      await db.execute('ALTER TABLE cart_items ADD COLUMN configId TEXT');
    }
  }

  Future<int> insertItem(CartItem item) async {
    final db = await database;
    return await db.insert(
      'cart_items',
      _toMap(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CartItem>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cart_items');

    return List.generate(maps.length, (i) {
      return _fromMap(maps[i]);
    });
  }

  Future<int> updateItem(CartItem item) async {
    final db = await database;
    // If identifying by ID (local ID)
    return await db.update(
      'cart_items',
      _toMap(item),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'cart_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }

  // Helper methods for conversion
  Map<String, dynamic> _toMap(CartItem item) {
    return {
      // id is auto-generated usually, but if we are updating, we need it. 
      // For insert, if id is 0 or null, sqflite ignores it if not sending it?
      // CartItem id is final int. If we create a new CartItem(id: 0) for insertion, we should verify if 0 works.
      // Usually better to exclude ID for insert if it's auto-increment.
      // But let's handle that in the Provider logic.
      if (item.id != 0) 'id': item.id,
      'productId': item.productId,
      'productName': item.productName,
      'productImageUrl': item.productImageUrl,
      'quantity': item.quantity,
      'unitPrice': item.unitPrice,
      'subtotal': item.subtotal,
      'currency': item.currency,
      'provider': item.provider,
      'stockStatus': item.stockStatus,
      'isAvailable': item.isAvailable ? 1 : 0,
      'priceWhenAdded': item.priceWhenAdded,
      'currentPrice': item.currentPrice,
      'priceDropped': item.priceDropped ? 1 : 0,
      'savingsAmount': item.savingsAmount,
      if (item.configId != null) 'configId': item.configId,
    };
  }

  CartItem _fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as int,
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      productImageUrl: map['productImageUrl'] as String? ?? '', // Handle null if legacy
      quantity: map['quantity'] as int,
      unitPrice: (map['unitPrice'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
      currency: map['currency'] as String,
      provider: map['provider'] as String? ?? '',
      stockStatus: map['stockStatus'] as String? ?? '',
      isAvailable: (map['isAvailable'] as int) == 1,
      priceWhenAdded: (map['priceWhenAdded'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (map['currentPrice'] as num?)?.toDouble() ?? 0.0,
      priceDropped: (map['priceDropped'] as int) == 1,
      savingsAmount: (map['savingsAmount'] as num?)?.toDouble() ?? 0.0,
      configId: map['configId'] as String?,
    );
  }
}
