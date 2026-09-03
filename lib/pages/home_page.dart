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
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(
                context,
                MaterialPageRoute(
                  builder: (context) => Profil(),
                ).settings.name!,
              );
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
                    child: _builCard(
                      Icons.person,
                      'Documents administratif',
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _builCard(
                      Icons.settings,
                      'Documents académiques',
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _builCard(
                      Icons.school,
                      'Documents financiers',
                      Colors.red,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _builCard(
                      Icons.book,
                      'Documents de recherche',
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _builCard(
                      Icons.work,
                      'Documents de travail',
                      Colors.grey,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _builCard(
                      Icons.folder,
                      'Estudiantines',
                      Colors.blue,
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

  Widget _builCard(IconData icon, String title, MaterialColor color) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 50),
          SizedBox(height: 10),
          Text(title, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
