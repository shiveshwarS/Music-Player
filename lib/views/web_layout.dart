import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hertzz/viewmodels/navigation_provider.dart';
import 'package:hertzz/viewmodels/library_provider.dart';
import 'package:hertzz/views/widgets/home_content.dart';
import 'package:hertzz/views/widgets/search_view.dart';
import 'package:hertzz/views/widgets/playlist_grid.dart';
import 'package:hertzz/views/widgets/playlist_page.dart';
import 'package:hertzz/views/widgets/play_bar.dart';
import 'package:hertzz/views/widgets/sidebar.dart';
import 'package:hertzz/views/widgets/hover_boxes.dart';

class WebLayout extends StatelessWidget {
  const WebLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final library = Provider.of<LibraryProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: library.loading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                const Sidebar(),
                Container(
                  width: 1,
                  color: Colors.grey.shade800.withOpacity(0.3),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: SafeArea(
                        child: Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Consumer<NavigationProvider>(
                                    builder: (context, value, child) {
                                      if (value.tabindex != 2 && value.playlist) {
                                        value.playlist = false;
                                      } else if (value.tabindex != 1 &&
                                          value.extras) {
                                        value.extras = false;
                                      }
                                      int pageIndex = (value.playlist ||
                                              value.extras)
                                          ? 2
                                          : value.tabindex;
                                      Widget page;
                                      if (pageIndex == 0) {
                                        page =
                                            SearchView(songs: library.allSongs);
                                      } else if (pageIndex == 2) {
                                        page = value.playlist || value.extras
                                            ? const PlaylistPage()
                                            : const PlaylistGrid();
                                      } else {
                                        page = HomeContent(
                                            songs: library.allSongs);
                                      }
                                      return AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 600),
                                        switchInCurve: Curves.fastOutSlowIn,
                                        switchOutCurve: Curves.fastOutSlowIn,
                                        child: page,
                                      );
                                    },
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: FadeEffect(
                                        width: double.infinity, height: 60),
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: PlayBar(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
