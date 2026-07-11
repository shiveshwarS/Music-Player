import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hertzz/viewmodels/navigation_provider.dart';
import 'package:hertzz/viewmodels/player_provider.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: Colors.grey.shade900,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_note_rounded,
                      color: Colors.deepOrange, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "Music Player",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'robo',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: Colors.grey.shade800.withOpacity(0.3),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SidebarItem(Icons.home_rounded, "Home", 1),
                    _SidebarItem(Icons.search_rounded, "Search", 0),
                    _SidebarItem(
                        Icons.playlist_play_rounded, "Playlists", 2),
                  ],
                ),
              ),
            ),
            Container(
              height: 1,
              color: Colors.grey.shade800.withOpacity(0.3),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Material(
                color: Colors.deepOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    final uri = Uri.parse(
                        "https://drive.google.com/file/d/1Vfs6lUtHUsBGX6WxIx8z2LQF8jgpOFXe/view?usp=drivesdk");
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.download_rounded,
                            color: Colors.deepOrange, size: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Download APK",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Consumer<PlayerProvider>(
              builder: (context, s, child) {
                return Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.music_note_rounded,
                          color: Colors.deepOrange, size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          s.curname ?? "No song playing",
                          style:
                              const TextStyle(color: Colors.white70, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;

  const _SidebarItem(this.icon, this.label, this.index);

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, tab, child) {
        final selected =
            tab.tabindex == index && !tab.playlist && !tab.extras;
        return Container(
          color:
              selected ? Colors.deepOrange.withOpacity(0.15) : Colors.transparent,
          child: ListTile(
            leading: Icon(icon,
                color: selected ? Colors.deepOrange : Colors.white54,
                size: 22),
            title: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            selected: selected,
            onTap: () {
              tab.tabindex = index;
              tab.playlist = false;
              tab.extras = false;
              tab.notify();
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          ),
        );
      },
    );
  }
}
