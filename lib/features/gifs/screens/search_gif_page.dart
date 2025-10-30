import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/controllers/gifs_controller.dart';
import '../widgets/gif_display.dart';
import '../../../data/services/giphy_service.dart';

class SearchGifPage extends StatefulWidget {
  const SearchGifPage({super.key});

  @override
  State<SearchGifPage> createState() => _SearchGifPageState();
}

class _SearchGifPageState extends State<SearchGifPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _rating = 'g';

  @override
  void initState() {
    super.initState();
    final controller = context.read<GifsController>();

    // Preenche o TextField com a última busca, se houver
    if (controller.lastQuery != null && controller.lastQuery!.isNotEmpty) {
      _searchController.text = controller.lastQuery!;
      controller.fetchGifs(controller.lastQuery!, rating: _rating);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final controller = context.read<GifsController>();

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (query.trim().isNotEmpty) {
        await controller.fetchGifs(query.trim(), rating: _rating);
        await controller.addHistory(query.trim()); // Salva no histórico
        controller.restartAutoShuffle();
      }
    });
  }

  void _onRatingChanged(String? value) {
    if (value == null) return;
    setState(() => _rating = value);

    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      final controller = context.read<GifsController>();
      controller.fetchGifs(query, rating: _rating);
      controller.restartAutoShuffle();
    }
  }

  Widget _buildGifItem(GiphyGif gif) {
    final controller = context.read<GifsController>();

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/detail', arguments: gif),
      child: GifDisplay(gif: gif, onFirstFrame: controller.trackOnLoad),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GifsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar GIFs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de busca + dropdown de rating
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar GIFs',
                      hintText: 'Digite algo...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _rating,
                  onChanged: _onRatingChanged,
                  items: const [
                    DropdownMenuItem(value: 'g', child: Text('G')),
                    DropdownMenuItem(value: 'pg', child: Text('PG')),
                    DropdownMenuItem(value: 'pg-13', child: Text('PG-13')),
                    DropdownMenuItem(value: 'r', child: Text('R')),
                  ],
                ),
              ],
            ),
          ),

          // Grid de GIFs
          Expanded(
            child: Builder(
              builder: (_) {
                if (controller.gridLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.gridError != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.gridError!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: controller.retryLastGridFetch,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.gifGrid.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum resultado encontrado.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    final query = _searchController.text.trim();
                    if (query.isNotEmpty) {
                      await controller.fetchGifs(query, rating: _rating);
                    }
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: controller.gifGrid.length,
                    itemBuilder: (context, index) {
                      final gif = controller.gifGrid[index];
                      return _buildGifItem(gif);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
