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
        title: Text('Home'),
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
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 6,
                children: [Icon(Icons.archive), Text('Archiver')],
              ),
              Row(
                spacing: 6,
                children: [Icon(Icons.logout), Text('Se déconnecter')],
              ),
            ],
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
                      title: 'Document administratifs',
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: MyCards(
                      icon: Icons.school,
                      color: Colors.orange,
                      title: 'Documents académiques',
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
                      title: 'Document financiers',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: MyCards(
                      icon: Icons.book,
                      color: Colors.brown,
                      title: 'Livres universitaires',
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
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: MyCards(
                      onTap: () {
                        context.go('/docetu');
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
