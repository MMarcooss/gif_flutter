import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // ---------------- Favoritos ----------------
  Future<void> addFavorite(String id, String title, String url) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];

    // Evita duplicatas
    favorites.removeWhere((e) => jsonDecode(e)['id'] == id);

    favorites.add(jsonEncode({'id': id, 'title': title, 'url': url}));
    await prefs.setStringList('favorites', favorites);
  }

  Future<void> removeFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    favorites.removeWhere((e) => jsonDecode(e)['id'] == id);
    await prefs.setStringList('favorites', favorites);
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    return favorites.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  Future<bool> isFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    return favorites.any((e) => jsonDecode(e)['id'] == id);
  }

  // ---------------- Histórico ----------------
  Future<void> addHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];

    history.add(
      jsonEncode({
        'query': query,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }),
    );

    if (history.length > 20) history = history.sublist(history.length - 20);

    await prefs.setStringList('history', history);
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];
    List<Map<String, dynamic>> decoded = history
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();

    decoded.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    return decoded;
  }

  // ---------------- Preferências ----------------
  Future<void> setPreference(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}
