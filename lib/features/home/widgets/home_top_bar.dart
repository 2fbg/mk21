import 'package:flutter/material.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.currentSection,
    this.showSearch = true,
    this.onSectionSelected,
  });

  final String currentSection;
  final bool showSearch;
  final ValueChanged<String>? onSectionSelected;

  static const _sections = ['Home', 'Canais', 'Filmes', 'Series'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0x55A18F2A), width: 1),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _sections.length; i++) ...[
            _NavItem(
              label: _sections[i],
              selected: _sections[i] == currentSection,
              onTap: onSectionSelected == null
                  ? null
                  : () => onSectionSelected!(_sections[i]),
            ),
            if (i != _sections.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '|',
                  style: TextStyle(color: Color(0x88FFFFFF), fontSize: 18),
                ),
              ),
          ],
          if (showSearch) ...[
            const SizedBox(width: 20),
            Container(
              width: 150,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x88B8A64A)),
                color: Colors.black.withOpacity(0.12),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 10),
                  Icon(Icons.search, size: 16, color: Colors.white70),
                ],
              ),
            ),
          ],
          const Spacer(),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white54),
            ),
            child: const Icon(Icons.play_arrow_rounded, size: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: selected ? const Color(0xFFD6C54A) : Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
