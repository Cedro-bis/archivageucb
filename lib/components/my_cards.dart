import 'package:archivageucb/export_pages.dart';

// ignore: must_be_immutable
class MyCards extends StatelessWidget {
  final IconData icon;
  final MaterialColor color;
  final String title;
  void Function()? onTap;
  MyCards({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 50),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
