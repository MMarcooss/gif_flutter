import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/controllers/gifs_controller.dart';
import '../../../data/services/giphy_service.dart';
import '../widgets/gif_display.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GifsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: FutureBuilder<List<GiphyGif>>(
        future: controller.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final gifs = snapshot.data ?? [];
          if (gifs.isEmpty) {
            return const Center(child: Text('Nenhum favorito ainda.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: gifs.length,
            itemBuilder: (context, index) {
              final gif = gifs[index];
              return GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, '/detail', arguments: gif),
                child: Image.network(gif.gifUrl ?? '', fit: BoxFit.cover),
              );
            },
          );
        },
      ),
    );
  }
}
