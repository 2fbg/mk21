import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/server_config.dart';
import '../../models/playlist_item.dart';
import '../../services/iptv_library_service.dart';
import '../../services/server_config_service.dart';
import '../live/live_page.dart';
import '../movies/movies_page.dart';
import '../series/series_page.dart';
import 'widgets/home_content_row.dart';
import 'widgets/home_top_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<_HomeLoadResult> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadLibrary();
  }

  Future<_HomeLoadResult> _loadLibrary() async {
    final config = await const ServerConfigService().load();
    if (config == null || config.playlistUrl.trim().isEmpty) {
      throw Exception('Nenhuma playlist salva. Configure um servidor primeiro.');
    }
    final uri = Uri.tryParse(config.playlistUrl.trim());
    if (uri == null) {
      throw Exception('URL da playlist inválida.');
    }
    final response = await http.get(uri, headers: {
      'User-Agent': config.userAgent,
      'Accept': '*/*',
      'Connection': 'keep-alive',
    }).timeout(const Duration(seconds: 35));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Falha ao baixar playlist. HTTP ${response.statusCode}.');
    }
    final content = response.body;
    if (!content.trimLeft().startsWith('#EXTM3U')) {
      throw Exception('O servidor respondeu, mas o conteúdo não parece ser uma lista M3U.');
    }
    final library = const IptvLibraryService().buildFromM3u(content);
    return _HomeLoadResult(config: config, library: library);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF041A12), Color(0xFF07170F), Color(0xFF17060B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<_HomeLoadResult>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFD6C54A)));
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    snapshot.error.toString(),
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              }
              final result = snapshot.data!;
              final live = result.library.liveItems.take(12).toList();
              final movies = result.library.movieItems.take(12).toList();
              final series = result.library.seriesItems.take(12).toList();
              final featured = live.isNotEmpty ? live.first : (movies.isNotEmpty ? movies.first : (series.isNotEmpty ? series.first : null));

              return Column(
                children: [
                  HomeTopBar(
                    currentSection: 'Home',
                    showSearch: false,
                    onSectionSelected: _openSection,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                      children: [
                        Container(
                          height: 210,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0x55B5A642)),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF062418), Color(0xFF072C18), Color(0xFF3A0815)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('MK21 MULTISERVIDOR', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2)),
                              const Spacer(),
                              Text(
                                featured?.name ?? 'Conteúdo em destaque',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Canais ${result.library.liveCount}  |  Filmes ${result.library.movieCount}  |  Séries ${result.library.seriesCount}',
                                style: const TextStyle(color: Color(0xFFD6C54A), fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        HomeContentRow(title: 'Canais', subtitle: '${result.library.liveCount}', items: live, icon: Icons.live_tv),
                        HomeContentRow(title: 'Filmes', subtitle: '${result.library.movieCount}', items: movies, icon: Icons.movie),
                        HomeContentRow(title: 'Séries', subtitle: '${result.library.seriesCount}', items: series, icon: Icons.video_library),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _openSection(String section) {
    if (section == 'Canais') {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LivePage()));
    } else if (section == 'Filmes') {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoviesPage()));
    } else if (section == 'Series') {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SeriesPage()));
    } else {
      setState(() => _future = _loadLibrary());
    }
  }
}

class _HomeLoadResult {
  const _HomeLoadResult({required this.config, required this.library});
  final ServerConfig config;
  final IptvLibrary library;
}
