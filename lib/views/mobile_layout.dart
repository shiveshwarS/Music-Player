import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hertzz/viewmodels/navigation_provider.dart';
import 'package:hertzz/viewmodels/library_provider.dart';
import 'package:hertzz/views/widgets/home_content.dart';
import 'package:hertzz/views/widgets/search_view.dart';
import 'package:hertzz/views/widgets/playlist_grid.dart';
import 'package:hertzz/views/widgets/playlist_page.dart';
import 'package:hertzz/views/widgets/play_bar.dart';
import 'package:hertzz/views/widgets/hover_boxes.dart';

class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final library = Provider.of<LibraryProvider>(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: library.loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Consumer<NavigationProvider>(
                          builder: (context, value, child) {
                            if (value.tabindex != 2 && value.playlist) {
                              value.playlist = false;
                            } else if (value.tabindex != 1 && value.extras) {
                              value.extras = false;
                            }
                            int pageIndex =
                                (value.playlist || value.extras) ? 2 : value.tabindex;
                            Widget page;
                            if (pageIndex == 0) {
                              page = SearchView(songs: library.allSongs);
                            } else if (pageIndex == 2) {
                              page = value.playlist || value.extras
                                  ? const PlaylistPage()
                                  : const PlaylistGrid();
                            } else {
                              page = HomeContent(songs: library.allSongs);
                            }
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 600),
                              switchInCurve: Curves.fastOutSlowIn,
                              switchOutCurve: Curves.fastOutSlowIn,
                              child: page,
                            );
                          },
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: FadeEffect(
                              width: double.infinity, height: 120),
                        ),
                      ],
                    ),
                  ),
                  const PlayBar(),
                ],
              ),
        bottomNavigationBar: Theme(
          data: ThemeData(
            canvasColor: Colors.grey.shade900,
            splashColor: Colors.transparent,
          ),
          child: Consumer<NavigationProvider>(
            builder: (context, value, child) => BottomNavigationBar(
              currentIndex: value.tabindex,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              elevation: 0,
              showUnselectedLabels: false,
              selectedFontSize: 10,
              type: BottomNavigationBarType.shifting,
              onTap: (val) {
                value.tabindex = val;
                value.notify();
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.search_rounded), label: "Search"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.playlist_play), label: "PlayLists"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
