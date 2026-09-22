import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FileViewerScreen extends StatelessWidget {
  final String fileName;
  final String fileUrl;

  const FileViewerScreen({
    super.key,
    required this.fileName,
    required this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.open_in_browser,
              size: 80,
              color: Color(0xFF0D47A1),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Ouverture de "$fileName"...',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.launch),
              label: const Text('Ouvrir dans le navigateur'),
              onPressed: () async {
                final Uri uri = Uri.parse(fileUrl);
                if (!await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                )) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Impossible d'ouvrir l'URL.")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
