import 'package:archivageucb/components/my_list_tile.dart';
import 'package:archivageucb/pages/supabase_category.dart';
import 'package:archivageucb/export_pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (builder) => Profil()),
                );
              },
            ),
          ),
        ],
      ),
      drawer: ListView(
        children: [
          DrawerHeader(
            child: Image.asset('lib/images/logo.png', width: 70, height: 70),
          ),
          MyListTile(
            icon: Icons.archive,
            title: 'Archiver',
            onTap: () {
              context.go('/upload');
            },
          ),
          MyListTile(
            icon: Icons.settings,
            title: 'Paramètres',
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          MyListTile(
            icon: Icons.logout,
            title: 'Se déconnecter',
            onTap: () {
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: MyCards(
                      icon: Icons.admin_panel_settings,
                      color: Colors.green,
                      title: 'Documents administratifs',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupabaseCategory(
                              categoryName: 'Document administratif',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: MyCards(
                      icon: Icons.school,
                      color: Colors.orange,
                      title: 'Documents académiques',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupabaseCategory(
                              categoryName: 'Documents académiques',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: MyCards(
                      icon: Icons.balance,
                      color: Colors.red,
                      title: 'Documents financiers',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupabaseCategory(
                              categoryName: 'Documents financiers',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: MyCards(
                      icon: Icons.book,
                      color: Colors.brown,
                      title: 'Livres universitaires',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupabaseCategory(
                              categoryName: 'Livres universitaires',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: MyCards(
                      icon: Icons.work,
                      color: Colors.cyan,
                      title: 'Travaux et projets',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupabaseCategory(
                              categoryName: 'Travaux et projets',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: MyCards(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupabaseCategory(
                              categoryName: 'Document estudiantins',
                            ),
                          ),
                        );
                      },
                      icon: Icons.folder,
                      color: Colors.lightBlue,
                      title: 'Documents estudiantins',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
