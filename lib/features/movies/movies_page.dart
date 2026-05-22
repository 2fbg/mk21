import 'package:flutter/material.dart';

import '../../services/demo_iptv_library_service.dart';
import '../shared/content_grid_page.dart';

class MoviesPage extends StatelessWidget {
  const MoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final library = DemoIptvLibraryService.load();
    return ContentGridPage(
      title: 'Filmes',
      items: library.movieItems,
      icon: Icons.movie,
    );
  }
}
