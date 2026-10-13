import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'common_widgets.dart';
import 'ui_helpers.dart';

class ShellTab {
  const ShellTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.builder,
    this.title,
    this.reloadOnVisit = false,
  });

  final String label;
  final String? title;
  final IconData icon;
  final IconData selectedIcon;
  final WidgetBuilder builder;
  final bool reloadOnVisit;
}

class ShellScope extends InheritedWidget {
  const ShellScope({super.key, required this.select, required super.child});

  final void Function(int index) select;

  static ShellScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ShellScope>();
    assert(scope != null, 'ShellScope not found in widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(ShellScope oldWidget) => false;
}

class ShellScaffold extends StatefulWidget {
  const ShellScaffold({super.key, required this.tabs});

  final List<ShellTab> tabs;

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold> {
  int _index = 0;
  late final List<bool> _visited = [
    for (var i = 0; i < widget.tabs.length; i++) i == 0,
  ];
  late final List<int> _visitCount = List.filled(widget.tabs.length, 0);

  void _select(int value) {
    setState(() {
      _index = value;
      _visited[value] = true;
      _visitCount[value]++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.tabs[_index];
    return ShellScope(
      select: _select,
      child: Scaffold(
        appBar: AppBar(title: Text(current.title ?? current.label)),
        drawer: _SideDrawer(
          tabs: widget.tabs,
          selected: _index,
          onSelect: _select,
        ),
        body: IndexedStack(
          index: _index,
          children: [
            for (var i = 0; i < widget.tabs.length; i++)
              if (_visited[i])
                KeyedSubtree(
                  key: ValueKey(widget.tabs[i].reloadOnVisit ? _visitCount[i] : 0),
                  child: Builder(builder: widget.tabs[i].builder),
                )
              else
                const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE8EAEF))),
          ),
          child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: [
            for (final tab in widget.tabs)
              NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.selectedIcon),
                label: tab.label,
              ),
          ],
        ),
        ),
      ),
    );
  }
}

class _SideDrawer extends StatelessWidget {
  const _SideDrawer({
    required this.tabs,
    required this.selected,
    required this.onSelect,
  });

  final List<ShellTab> tabs;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final session = auth.session;
    final name = session?.name ?? '';
    final role = session?.roleLabel ?? '';

    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 24,
              20,
              24,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(topRight: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: UserAvatar(name: name, radius: 30),
                ),
                const SizedBox(height: 14),
                Text(
                  name.isEmpty ? 'Welcome' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              children: [
                for (var i = 0; i < tabs.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: ListTile(
                      selected: i == selected,
                      selectedTileColor: theme.colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      leading: Icon(i == selected ? tabs[i].selectedIcon : tabs[i].icon),
                      title: Text(
                        tabs[i].title ?? tabs[i].label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onSelect(i);
                      },
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                leading: const Icon(Icons.logout_rounded, color: Color(0xFFB91C1C)),
                title: const Text(
                  'Log out',
                  style: TextStyle(
                    color: Color(0xFFB91C1C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () async {
                  final nav = Navigator.of(context);
                  final ok = await confirm(
                    context,
                    title: 'Log out',
                    message: 'Are you sure you want to log out?',
                    confirmLabel: 'Log out',
                  );
                  if (!ok) return;
                  nav.pop();
                  await auth.logout();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
