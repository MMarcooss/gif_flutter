import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'data/controllers/gifs_controller.dart';
import 'data/services/giphy_service.dart';
import 'features/gifs/screens/search_gif_page.dart';
import 'features/gifs/screens/favorite_page.dart';
import 'features/gifs/screens/history_page.dart';
import 'features/gifs/screens/detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa SQLite para desktop (Windows, Linux, macOS)
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => GifsController(
        GiphyService(apiKey: 'rChJ5NMYZpcpTPSmd1namHCqbUr7bY3P'),
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GIF Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SearchGifPage(),
        '/favorites': (_) => const FavoritesPage(),
        '/history': (_) => const HistoryPage(),
      },
      onGenerateRoute: (settings) {
        // Rota dinâmica para GifDetailPage
        if (settings.name == '/detail') {
          final args = settings.arguments;
          if (args is GiphyGif) {
            return MaterialPageRoute(builder: (_) => GifDetailPage(gif: args));
          } else {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text(
                    'Erro: argumento inválido para GifDetailPage',
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ),
              ),
            );
          }
        }
        return null; // Retorna null para rotas inexistentes
      },
    );
  }
}
