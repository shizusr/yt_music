import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(YTDownloaderApp());
}

class YTDownloaderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube to MP3 Downloader',
      theme: ThemeData.dark(),
      home: DownloaderScreen(),
    );
  }
}

class DownloaderScreen extends StatefulWidget {
  @override
  _DownloaderScreenState createState() => _DownloaderScreenState();
}

class _DownloaderScreenState extends State<DownloaderScreen> {
  final _urlsController = TextEditingController();
  final List<String> _logs = [];
  bool _isDownloading = false;

  void _log(String message) {
    setState(() {
      _logs.add(message);
    });
  }

  Future<void> _downloadAll() async {
    final rawInput = _urlsController.text.trim();

    if (rawInput.isEmpty) {
      _log('⛔️ No URLs provided.');
      return;
    }

    final urls = rawInput
        .split('\n')
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList();

    if (urls.isEmpty) {
      _log('⛔️ Invalid input.');
      return;
    }

    setState(() {
      _isDownloading = true;
      _logs.clear();
    });

    for (var i = 0; i < urls.length; i++) {
      final url = urls[i];
      _log('⬇️ (${i + 1}/${urls.length}) Downloading: $url');

      try {
        final result = await Process.run('yt-dlp', [
          '--extract-audio',
          '--audio-format',
          'mp3',
          '-o',
          '~/Music/%(title)s.%(ext)s',
          url,
        ]);

        if (result.exitCode == 0) {
          _log('✅ Done: $url');
        } else {
          _log('❌ Error: $url\n${result.stderr}');
        }
      } catch (e) {
        _log('❌ System error: $e');
      }
    }

    setState(() {
      _isDownloading = false;
    });

    _log('🏁 All downloads complete!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('YouTube ➤ MP3 Bulk Downloader')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlsController,
              decoration: InputDecoration(
                labelText: 'Paste YouTube links (one per line)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 6,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isDownloading ? null : _downloadAll,
              icon: Icon(Icons.download),
              label: Text('Download all as MP3'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                color: Colors.black26,
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return Text(_logs[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}