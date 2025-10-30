import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

const String _baseUrl = 'https://api.giphy.com/v1';

class GiphyService {
  final String apiKey;
  String? _randomId;
  static const _favoritesKey = 'favorites';
  static const _historyKey = 'history';
  static const _prefsKey = 'preferences';

  GiphyService({required this.apiKey});

  /// Inicializa o random_id (necessário para analytics)
  /// Busca do cache ou faz uma chamada à API
  Future<void> initRandomId() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('giphy_random_id');

    if (cached != null && cached.isNotEmpty) {
      _randomId = cached;
      return;
    }

    if (apiKey.isEmpty) return;

    final uri = Uri.parse('$_baseUrl/randomid?api_key=$apiKey');
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final id = (json['data']?['random_id'] ?? '') as String;
        if (id.isNotEmpty) {
          _randomId = id;
          await prefs.setString('giphy_random_id', id);
        }
      }
    } catch (_) {
      // Segue sem random_id se falhar
    }
  }

  /// Busca um GIF aleatório
  Future<GiphyGif?> fetchRandomGif({String? tag, String rating = 'g'}) async {
    if (apiKey.isEmpty) {
      throw Exception('API key não definida');
    }

    final params = <String, String>{
      'api_key': apiKey,
      if (tag != null && tag.trim().isNotEmpty) 'tag': tag.trim(),
      if (rating.isNotEmpty) 'rating': rating,
      if (_randomId != null) 'random_id': _randomId!,
    };

    final uri = Uri.https('api.giphy.com', '/v1/gifs/random', params);

    try {
      final res = await http.get(uri, headers: {'Accept': 'application/json'});

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>?;

        if (data == null || data.isEmpty) return null;

        return GiphyGif.fromJson(data);
      } else {
        throw Exception('Erro ${res.statusCode} ao buscar GIF');
      }
    } catch (e) {
      throw Exception('Falha de rede: $e');
    }
  }

  /// Busca vários GIFs por termo de pesquisa (para o grid)
  Future<List<GiphyGif>> searchGifs(
    String query, {
    int limit = 25,
    int offset = 0,
    String rating = 'g',
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('API key não definida');
    }

    final params = <String, String>{
      'api_key': apiKey,
      'q': query,
      'limit': '$limit',
      'offset': '$offset',
      'rating': rating,
      'lang': 'en',
    };

    final uri = Uri.https('api.giphy.com', '/v1/gifs/search', params);

    try {
      final res = await http.get(uri, headers: {'Accept': 'application/json'});

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final data = json['data'] as List<dynamic>;

        return data.map((item) => GiphyGif.fromJson(item)).toList();
      } else {
        throw Exception('Erro ${res.statusCode} ao buscar GIFs');
      }
    } catch (e) {
      throw Exception('Falha de rede: $e');
    }
  }

  // -------- FAVORITOS --------
  Future<void> addFavorite(GiphyGif gif) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = await getFavorites();

    if (favs.indexWhere((f) => f['id'] == gif.id) == -1) {
      favs.add(gif.toJson());
      await prefs.setString(_favoritesKey, jsonEncode(favs));
    }
  }

  Future<void> removeFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = await getFavorites();
    favs.removeWhere((f) => f['id'] == id);
    await prefs.setString(_favoritesKey, jsonEncode(favs));
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritesKey);
    if (jsonString == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
  }

  Future<bool> isFavorite(String id) async {
    final favs = await getFavorites();
    return favs.any((f) => f['id'] == id);
  }

  // -------- HISTÓRICO --------
  Future<void> addHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    history.removeWhere((h) => h['query'] == query);
    history.insert(0, {'query': query});

    if (history.length > 20) history.removeLast();
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    if (jsonString == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
  }

  // -------- PREFERÊNCIAS --------
  Future<void> setPreference(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    final prefsMap = await getAllPreferences();
    prefsMap[key] = value;
    await prefs.setString(_prefsKey, jsonEncode(prefsMap));
  }

  Future<String?> getPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString == null) return null;
    final Map<String, dynamic> decoded = jsonDecode(jsonString);
    return decoded[key];
  }

  Future<Map<String, dynamic>> getAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString == null) return {};
    return Map<String, dynamic>.from(jsonDecode(jsonString));
  }

  /// Envia ping de analytics (fire-and-forget)
  Future<void> pingAnalytics(String? url) async {
    if (url == null) return;

    try {
      final uri = Uri.parse(url).replace(
        queryParameters: {
          ...Uri.parse(url).queryParameters,
          if (_randomId != null) 'random_id': _randomId!,
          'ts': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
      await http.get(uri).timeout(const Duration(seconds: 3));
    } catch (_) {
      // Silencioso
    }
  }

  /// Retorna o random_id atual (útil para debug)
  String? get randomId => _randomId;
}

/// Modelo de dados para um GIF do Giphy
class GiphyGif {
  final String? id;
  final String? title;
  final String? username;
  final String? gifUrl;
  final String? analyticsOnLoad;
  final String? analyticsOnClick;

  GiphyGif({
    this.id,
    this.title,
    this.username,
    this.gifUrl,
    this.analyticsOnLoad,
    this.analyticsOnClick,
  });

  factory GiphyGif.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] ?? {}) as Map<String, dynamic>;
    final downsized = images['downsized_medium'] as Map<String, dynamic>?;
    final original = images['original'] as Map<String, dynamic>?;
    final url = (downsized?['url'] ?? original?['url']) as String?;

    final analytics = (json['analytics'] ?? {}) as Map<String, dynamic>;
    final onload = (analytics['onload']?['url']) as String?;
    final onclick = (analytics['onclick']?['url']) as String?;

    return GiphyGif(
      id: json['id'] as String?,
      title: (json['title'] ?? 'Random GIF') as String?,
      username: (json['username'] ?? 'Desconhecido') as String?,
      gifUrl: url,
      analyticsOnLoad: onload,
      analyticsOnClick: onclick,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'gifUrl': gifUrl,
      'analyticsOnLoad': analyticsOnLoad,
      'analyticsOnClick': analyticsOnClick,
    };
  }
}
