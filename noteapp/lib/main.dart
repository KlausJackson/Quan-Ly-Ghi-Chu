import 'package:flutter/material.dart';
import 'package:noteapp/data/sources/local.dart';
import 'package:noteapp/data/sources/remote.dart';
import 'package:noteapp/data/services/auth_service.dart';
import 'package:noteapp/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:noteapp/presentation/screens/notes/note_list.dart';
// import 'package:noteapp/presentation/screens/tags/tag_list.dart';
// import 'package:noteapp/presentation/screens/trash/trash_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Local.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => Remote()),
        Provider(create: (_) => Local()),
        ProxyProvider2<Remote, Local, AuthService>(
          update: (_, remote, local, __) => AuthService(remote, local),
        ),
        ChangeNotifierProxyProvider<AuthService, AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthService>()),
          update: (_, authService, __) => AuthProvider(authService),
        ),

        // NoteProvider, TagProvider, SyncProvider
      ],
      child: MaterialApp(
        title: 'NoteApp',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primarySwatch: Colors.indigo,
          appBarTheme: const AppBarTheme(
            elevation: 1, // subtle shadow
            centerTitle: true,
          ),
        ),
        home: const MainLayoutScreen(),
      ),
    );
  }
}

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    final List<Widget> screens = [
      NoteListScreen(currentUser: currentUser),
      const Center(child: Text('Tags List')),
      const Center(child: Text('Trash')),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Ghi chú'),
          BottomNavigationBarItem(icon: Icon(Icons.label), label: 'Thẻ'),
          BottomNavigationBarItem(icon: Icon(Icons.delete), label: 'Rác'),
        ],
      ),
    );
  }
}
