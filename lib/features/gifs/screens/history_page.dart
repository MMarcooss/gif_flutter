import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/controllers/gifs_controller.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final GifsController _controller;
  bool _loading = true;
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _controller = context.read<GifsController>();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _controller.getHistory();
    setState(() {
      _history = history;
      _loading = false;
    });
  }

  void _searchFromHistory(String query) {
    Navigator.pushNamed(context, '/search').then((_) {
      final controller = context.read<GifsController>();
      controller.fetchGifs(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/'),
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? const Center(child: Text('Nenhuma busca recente.'))
          : ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: _history.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final query = _history[index];
                return ListTile(
                  title: Text(query),
                  leading: const Icon(Icons.history),
                  trailing: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _searchFromHistory(query),
                  ),
                );
              },
            ),
    );
  }
}
