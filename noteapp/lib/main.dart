import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// --- CORE IMPORTS ---
import 'package:noteapp/core/local_db.dart';
import 'package:noteapp/core/api_client.dart';
import 'package:noteapp/core/network_info.dart';

// --- AUTH IMPORTS ---
import 'package:noteapp/features/auth/auth_local.dart';
import 'package:noteapp/features/auth/auth_remote.dart';
import 'package:noteapp/features/auth/auth_repository.dart';
import 'package:noteapp/features/auth/auth_provider.dart';
import 'package:noteapp/features/auth/user_model.dart';
import 'package:noteapp/presentations/screens/auth/auth_page.dart';

// --- TAG IMPORTS ---
import 'package:noteapp/features/tags/tag_local.dart';
import 'package:noteapp/features/tags/tag_remote.dart';
import 'package:noteapp/features/tags/tag_repository.dart';
import 'package:noteapp/features/tags/tag_provider.dart';
import 'package:noteapp/presentations/screens/tags/tag_page.dart';

// --- NOTE IMPORTS ---
import 'package:noteapp/features/notes/note_local.dart';
import 'package:noteapp/features/notes/note_remote.dart';
import 'package:noteapp/features/notes/note_repository.dart';
import 'package:noteapp/features/notes/note_provider.dart';
import 'package:noteapp/presentations/screens/notes/note_page.dart';
import 'package:noteapp/presentations/screens/notes/edit_page.dart';
import 'package:noteapp/presentations/screens/notes/trash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive & Core
  await LocalDb.init();
  const secureStorage = FlutterSecureStorage();
  final apiClient = ApiClient();
  final networkInfo = NetworkInfo();

  // 2. Initialize Data Sources
  final authLocal = AuthLocal(
    secureStorage: secureStorage,
    profilesBox: Hive.box<UserModel>(LocalDb.authBoxName),
  );
  final authRemote = AuthRemote(apiClient: apiClient);

  final tagLocal = TagLocal();
  final tagRemote = TagRemote(apiClient: apiClient);

  final noteLocal = NoteLocal();
  final noteRemote = NoteRemote(apiClient: apiClient);

  // 3. Initialize Repositories
  final authRepo = AuthRepository(
    remote: authRemote,
    local: authLocal,
    noteLocal: noteLocal, // for cleanup when deleting user
    tagLocal: tagLocal, // for cleanup when deleting user
  );

  final tagRepo = TagRepository(
    remote: tagRemote,
    local: tagLocal,
    authLocal: authLocal, // to check current user
  );

  final noteRepo = NoteRepository(
    remote: noteRemote,
    local: noteLocal,
    authLocal: authLocal,
    tagLocal: tagLocal, // to extract tags from notes
  );

  runApp(
    MultiProvider(
      providers: [
        // 4. Initialize Providers (State Management)
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepo)),
        ChangeNotifierProvider(create: (_) => TagProvider(tagRepo)),
        ChangeNotifierProvider(create: (_) => NoteProvider(noteRepo)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigoAccent,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      // Define Routes
      routes: {
        '/': (context) => const MainLayoutScreen(),
        '/auth': (context) => const AuthPage(),
        '/notes/create': (context) =>
            const NoteEditPage(), // Create mode (arg is null)
        '/notes/edit': (context) {
          // Argument extraction for Edit mode
          final args = ModalRoute.of(context)!.settings.arguments;
          return NoteEditPage(note: args as dynamic);
        },
        '/tags': (context) => const TagPage(),
        '/trash': (context) => const TrashPage(),
        '/notes': (context) => const NotesPage(),
      },
      initialRoute: '/',
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

  final List<Widget> _screens = const [NotesPage(), TagPage(), TrashPage()];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
               title: Text(authProvider.currentUser),
              leading: IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () {
                  Navigator.pushNamed(context, '/auth');
                },
              ),
              actions: [
                if (authProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),

      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.label_outlined),
            selectedIcon: Icon(Icons.label),
            label: 'Tags',
          ),
          NavigationDestination(
            icon: Icon(Icons.delete_outline),
            selectedIcon: Icon(Icons.delete),
            label: 'Trash',
          ),
        ],
      ),
    );
  }
}
