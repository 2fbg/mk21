import 'package:flutter/material.dart';

import '../../models/playlist_item.dart';
import '../home/widgets/home_top_bar.dart';
import '../player/player_page.dart';

class ContentGridPage extends StatefulWidget {
  const ContentGridPage({
    super.key,
    required this.title,
    required this.items,
    required this.icon,
  });

  final String title;
  final List<PlaylistItem> items;
  final IconData icon;

  @override
  State<ContentGridPage> createState() => _ContentGridPageState();
}

class _ContentGridPageState extends State<ContentGridPage> {
  late String _selectedCategory;
  int _selectedIndex = 0;

  List<String> get _categories {
    final set = <String>{'Todos'};
    for (final item in widget.items) {
      final parts = item.groupTitle.split('|');
      final value = parts.isNotEmpty ? parts.last.trim() : item.groupTitle.trim();
      set.add(value.isEmpty ? 'Sem categoria' : value);
    }
    return set.toList();
  }

  List<PlaylistItem> get _filteredItems {
    if (_selectedCategory == 'Todos') return widget.items;
    return widget.items.where((item) {
      final parts = item.groupTitle.split('|');
      final value = parts.isNotEmpty ? parts.last.trim() : item.groupTitle.trim();
      final group = value.isEmpty ? 'Sem categoria' : value;
      return group == _selectedCategory;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = 'Todos';
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFD6C54A);
    final isLive = widget.title == 'Canais';
    final items = _filteredItems;
    if (_selectedIndex >= items.length) _selectedIndex = 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF051911), Color(0xFF07150F), Color(0xFF1A0509)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              HomeTopBar(
                currentSection: widget.title == 'Séries' ? 'Series' : widget.title,
                showSearch: true,
                onSectionSelected: (section) {
                  if (section == 'Home') {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                  child: Row(
                    children: [
                      _CategoryPanel(
                        title: widget.title,
                        icon: widget.icon,
                        categories: _categories,
                        selectedCategory: _selectedCategory,
                        itemCount: items.length,
                        onSelect: (value) => setState(() {
                          _selectedCategory = value;
                          _selectedIndex = 0;
                        }),
                      ),
                      Expanded(
                        child: isLive
                            ? _LiveLayout(
                                items: items,
                                selectedIndex: _selectedIndex,
                                onSelect: (index) => setState(() => _selectedIndex = index),
                              )
                            : _VodLayout(
                                items: items,
                                selectedIndex: _selectedIndex,
                                accent: accent,
                                onSelect: (index) => setState(() => _selectedIndex = index),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPanel extends StatelessWidget {
  const _CategoryPanel({
    required this.title,
    required this.icon,
    required this.categories,
    required this.selectedCategory,
    required this.itemCount,
    required this.onSelect,
  });

  final String title;
  final IconData icon;
  final List<String> categories;
  final String selectedCategory;
  final int itemCount;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 176,
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        border: const Border(right: BorderSide(color: Color(0x55A18F2A))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.transparent,
            child: Icon(icon, color: Colors.white70, size: 40),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(Icons.reply, size: 14, color: Colors.white70),
              SizedBox(width: 6),
              Text('Voltar', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.search, size: 14, color: Colors.white70),
              SizedBox(width: 6),
              Text('Procurar', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 3),
              itemBuilder: (context, index) {
                final category = categories[index];
                final selected = category == selectedCategory;
                return InkWell(
                  onTap: () => onSelect(category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0x33D6C54A) : const Color(0x552B2B31),
                      border: Border.all(color: selected ? const Color(0x88D6C54A) : Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: selected ? const Color(0xFFD6C54A) : Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          index == 0 ? '$itemCount' : '',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
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

class _LiveLayout extends StatelessWidget {
  const _LiveLayout({
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<PlaylistItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final selected = items.isNotEmpty ? items[selectedIndex] : null;
    return Row(
      children: [
        Container(
          width: 285,
          margin: const EdgeInsets.only(left: 4),
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final active = index == selectedIndex;
              return InkWell(
                onTap: () => onSelect(index),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: active ? const Color(0x55363236) : const Color(0xAA2A2830),
                    border: Border(
                      left: BorderSide(color: active ? const Color(0xFFD6C54A) : Colors.transparent, width: 2),
                      top: const BorderSide(color: Colors.white10),
                      right: const BorderSide(color: Colors.white12),
                      bottom: const BorderSide(color: Colors.white10),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${index + 712}',
                          style: const TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: active ? const Color(0xFFD6C54A) : Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(4, 0, 6, 6),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0x55A18F2A)),
              gradient: const LinearGradient(
                colors: [Color(0xFF04431F), Color(0xFF04331A), Color(0xFF4B0914)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: selected == null
                ? const SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            selected.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        color: const Color(0x9909080A),
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selected.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(selected.groupTitle.isEmpty ? 'Canal ao vivo' : selected.groupTitle, style: const TextStyle(color: Color(0xFFD6C54A), fontSize: 11)),
                            const SizedBox(height: 8),
                            Row(
                              children: const [
                                _BottomAction(label: 'Alcançar'),
                                SizedBox(width: 6),
                                _BottomAction(label: 'Adicionar aos favoritos'),
                                SizedBox(width: 6),
                                _BottomAction(label: 'Procurar'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _VodLayout extends StatelessWidget {
  const _VodLayout({
    required this.items,
    required this.selectedIndex,
    required this.accent,
    required this.onSelect,
  });

  final List<PlaylistItem> items;
  final int selectedIndex;
  final Color accent;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0x66353439),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text('Ordenar por Adição', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ),
              const Spacer(),
              Text('Todos(${items.length})', style: const TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                childAspectRatio: 0.63,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                final active = index == selectedIndex;
                return InkWell(
                  onTap: () => onSelect(index),
                  onDoubleTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayerPage(item: item))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: active ? accent : Colors.white10, width: active ? 2 : 1),
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(colors: [Colors.grey.shade900, Colors.grey.shade800]),
                          ),
                          child: item.logoUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: Image.network(
                                    item.logoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _posterFallback(item.name),
                                  ),
                                )
                              : _posterFallback(item.name),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _posterFallback(String name) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      child: Text(
        name,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: const Color(0x66504B56),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }
}
