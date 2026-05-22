import 'package:flutter/material.dart';

import '../../services/demo_iptv_library_service.dart';
import '../shared/content_grid_page.dart';

class SeriesPage extends StatelessWidget {
  const SeriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final library = DemoIptvLibraryService.load();
    return ContentGridPage(
      title: 'Séries',
      items: library.seriesItems,
      icon: Icons.video_library,
    );
  }
}
