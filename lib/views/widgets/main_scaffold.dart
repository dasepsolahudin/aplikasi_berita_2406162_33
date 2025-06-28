import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inews/routes/route_name.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  int _calculateBottomAppBarIndex(BuildContext context) {
    final GoRouterState state = GoRouterState.of(context);
    final String? currentRouteName = state.topRoute?.name;
    final String location = state.uri.toString();

    if (currentRouteName == RouteName.home ||
        location.startsWith('/${RouteName.home}')) {
      return 0;
    }
    if (currentRouteName == RouteName.bookmark ||
        location.startsWith('/${RouteName.bookmark}')) {
      return 1;
    }
    if (currentRouteName == RouteName.localArticles ||
        location.startsWith('/${RouteName.localArticles}')) {
      return 2;
    }
    if (currentRouteName == RouteName.profile ||
        location.startsWith('/${RouteName.profile}')) {
      return 3;
    }
    return 0;
  }

  void _onBottomAppBarItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed(RouteName.home);
        break;
      case 1:
        context.goNamed(RouteName.bookmark);
        break;
      case 2:
        context.goNamed(RouteName.localArticles);
        break;
      case 3:
        context.goNamed(RouteName.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _calculateBottomAppBarIndex(context);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      // PERUBAHAN UTAMA: Hapus atau set extendBody ke false.
      // extendBody: true, // Baris ini dihapus agar body tidak berada di belakang nav bar.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.goNamed(RouteName.addLocalArticle);
        },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildFloatingNavBar(context, theme, selectedIndex),
      body: child,
    );
  }

  Widget _buildFloatingNavBar(
    BuildContext context,
    ThemeData theme,
    int selectedIndex,
  ) {
    // Tata letak bilah navigasi disesuaikan agar tidak lagi memerlukan BackdropFilter
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      // Memberi warna latar belakang yang solid sesuai dengan scaffold
      color: theme.scaffoldBackgroundColor,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        decoration: BoxDecoration(
          // Menggunakan warna kartu yang solid karena tidak lagi transparan
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavBarItem(
              context,
              theme,
              Icons.home_outlined,
              Icons.home_filled,
              "Home",
              0,
              selectedIndex,
            ),
            _buildNavBarItem(
              context,
              theme,
              Icons.bookmark_border,
              Icons.bookmark,
              "Bookmark",
              1,
              selectedIndex,
            ),
            _buildNavBarItem(
              context,
              theme,
              Icons.article_outlined,
              Icons.article,
              "Local",
              2,
              selectedIndex,
            ),
            _buildNavBarItem(
              context,
              theme,
              Icons.person_outline,
              Icons.person,
              "Profile",
              3,
              selectedIndex,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    IconData selectedIcon,
    String label,
    int index,
    int selectedIndex,
  ) {
    final bool isSelected = index == selectedIndex;
    final Color itemColor = isSelected ? Colors.black : theme.hintColor;

    return InkWell(
      onTap: () => _onBottomAppBarItemTapped(index, context),
      borderRadius: BorderRadius.circular(30.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.black.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? selectedIcon : icon, color: itemColor, size: 22),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  label,
                  style: TextStyle(
                    color: itemColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
