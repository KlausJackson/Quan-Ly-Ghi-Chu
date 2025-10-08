import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notes/core/routing/app_routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Phần trên
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 20), // Dịch lên trên 12px
              children: <Widget>[
                const DrawerHeader(
                  decoration: BoxDecoration(
                    // color: Colors.blue,
                  ),
                  child: Text(
                    'NOTES',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Trang chủ'),
                  onTap: () => context.go(AppRoutes.home),
                ),
                ListTile(
                  leading: const Icon(Icons.label),
                  title: const Text('Tags'),
                  onTap: () => context.go(AppRoutes.home),
                ),
                ListTile(
                  leading: const Icon(Icons.recycling),
                  title: const Text('Thùng rác'),
                  onTap: () => context.push(AppRoutes.trash),
                ),
              ],
            ),
          ),
          // Phần dưới cùng
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Đăng xuất"),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/logout');
            },
          ),
        ],
      ),
    );
  }
}
