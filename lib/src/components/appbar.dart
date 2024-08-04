import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:switch_learning/src/theme/theme.dart';
import 'package:switch_learning/src/theme/theme_provider.dart';

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MainAppBar(this.title, {super.key});
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<MainAppBar> createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceTint,
      title: Text(widget.title),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          onPressed: () {
            Provider.of<ThemeProvider>(context, listen: false).toggleMisc();
          },
          icon: Provider.of<ThemeProvider>(context).showMisc ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
        ),
        IconButton(
          onPressed: () {
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          },
          icon: Provider.of<ThemeProvider>(context).themeData == lightMode
              ? Image.asset(
                  "assets/images/Sun_icon.webp",
                )
              : Image.asset(
                  "assets/images/Eclipse.webp",
                ),
        ),
      ],
    );
  }
}
