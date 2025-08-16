import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

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
  String _downloadDirectory = '';
  List<FileSystemEntity> _musicFiles = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSavedDirectory();
  }

  Future<void> _loadSavedDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDir = prefs.getString('downloadDirectory');

    if (savedDir != null && await Directory(savedDir).exists()) {
      setState(() {
        _downloadDirectory = savedDir;
      });
    } else {
      // Default to Documents directory if no saved directory exists
      Directory dir = await getApplicationDocumentsDirectory();
      setState(() {
        _downloadDirectory = dir.path;
      });
    }
    _refreshMusicFiles();
  }

  Future<void> _saveDirectory(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('downloadDirectory', path);
  }

  Future<void> _refreshMusicFiles() async {
    final dir = Directory(_downloadDirectory);
    if (await dir.exists()) {
      final files = await dir.list().toList();
      setState(() {
        _musicFiles = files
            .where((file) => path.extension(file.path).toLowerCase() == '.mp3')
            .toList();
      });
    }
  }

  Future<void> _changeDownloadDirectory() async {
    final newDir = await showDialog<String>(
      context: context,
      builder: (context) => DirectoryPickerDialog(
        initialDirectory: _downloadDirectory,
      ),
    );

    if (newDir != null && newDir != _downloadDirectory) {
      setState(() {
        _downloadDirectory = newDir;
      });
      await _saveDirectory(newDir);
      _refreshMusicFiles();
    }
  }

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
          '$_downloadDirectory/%(title)s.%(ext)s',
          url,
        ]);

        if (result.exitCode == 0) {
          _log('✅ Done: $url');
          _refreshMusicFiles();
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
      appBar: AppBar(
        title: Text('YouTube ➤ MP3 Bulk Downloader'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // Use theme color
        elevation: 2, // Fixed elevation
        scrolledUnderElevation: 0, // Disables elevation change on scroll
      ),      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Download to: $_downloadDirectory',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.folder),
                  onPressed: _isDownloading ? null : _changeDownloadDirectory,
                  tooltip: 'Change download directory',
                ),
              ],
            ),
            SizedBox(height: 8),
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
              flex: 2,
              child: Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Music Files in Directory',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Divider(height: 1),
                    Expanded(
                      child: _musicFiles.isEmpty
                          ? Center(child: Text('No MP3 files found'))
                          : ListView.builder(
                        controller: _scrollController,
                        itemCount: _musicFiles.length,
                        itemBuilder: (context, index) {
                          final file = _musicFiles[index];
                          return Container(
                            color: Theme.of(context).cardColor, // Fixed background color
                            child: ListTile(
                              leading: Icon(Icons.music_note),
                              title: Text(
                                path.basename(file.path),
                                style: TextStyle(color: Colors.white), // Fixed text color
                              ),
                              trailing: Text(
                                '${(File(file.path).lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Download Logs',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          return Text(_logs[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DirectoryPickerDialog extends StatefulWidget {
  final String initialDirectory;

  const DirectoryPickerDialog({required this.initialDirectory});

  @override
  _DirectoryPickerDialogState createState() => _DirectoryPickerDialogState();
}

class _DirectoryPickerDialogState extends State<DirectoryPickerDialog> {
  late String _currentPath;
  List<FileSystemEntity> _contents = [];
  bool _isLoading = false;
  List<String> _pathHistory = [];
  int _currentHistoryIndex = -1;

  @override
  void initState() {
    super.initState();
    _currentPath = widget.initialDirectory; // Initialize with the provided directory
    _initializeDirectory();
  }

  Future<void> _initializeDirectory() async {
    setState(() => _isLoading = true);
    try {
      // Verify the initial directory exists
      if (!await Directory(_currentPath).exists()) {
        // Fallback to root directory if initial directory doesn't exist
        _currentPath = Platform.isWindows ? 'C:\\' : '/';
      }

      _pathHistory = [_currentPath];
      _currentHistoryIndex = 0;
      await _loadDirectoryContents();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDirectoryContents() async {
    setState(() => _isLoading = true);
    try {
      final dir = Directory(_currentPath);
      if (await dir.exists()) {
        final contents = await dir.list().toList();
        contents.sort((a, b) {
          if (a is Directory && b is! Directory) return -1;
          if (a is! Directory && b is Directory) return 1;
          return a.path.compareTo(b.path);
        });
        setState(() => _contents = contents);
      }
    } catch (e) {
      _contents = [];
      print('Error loading directory: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateTo(String newPath) {
    setState(() {
      _currentPath = newPath;
      // Update history
      if (_currentHistoryIndex < _pathHistory.length - 1) {
        _pathHistory = _pathHistory.sublist(0, _currentHistoryIndex + 1);
      }
      _pathHistory.add(newPath);
      _currentHistoryIndex++;
    });
    _loadDirectoryContents();
  }

  bool get _canGoBack => _currentHistoryIndex > 0;
  bool get _canGoForward => _currentHistoryIndex < _pathHistory.length - 1;

  void _goBack() {
    if (_canGoBack) {
      setState(() => _currentHistoryIndex--);
      _currentPath = _pathHistory[_currentHistoryIndex];
      _loadDirectoryContents();
    }
  }

  void _goForward() {
    if (_canGoForward) {
      setState(() => _currentHistoryIndex++);
      _currentPath = _pathHistory[_currentHistoryIndex];
      _loadDirectoryContents();
    }
  }

  void _goUp() {
    final parentDir = Directory(_currentPath).parent;
    _navigateTo(parentDir.path);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Download Directory'),
      content: Container(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            // Navigation buttons
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _canGoBack ? _goBack : null,
                  tooltip: 'Back',
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _canGoForward ? _goForward : null,
                  tooltip: 'Forward',
                ),
                IconButton(
                  icon: Icon(Icons.arrow_upward),
                  onPressed: _goUp,
                  tooltip: 'Up',
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      _currentPath,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  final entity = _contents[index];
                  final isDirectory = entity is Directory;
                  return ListTile(
                    leading: Icon(
                      isDirectory ? Icons.folder : Icons.insert_drive_file,
                      color: isDirectory ? Colors.amber : null,
                    ),
                    title: Text(path.basename(entity.path)),
                    onTap: isDirectory
                        ? () => _navigateTo(entity.path)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _currentPath),
          child: Text('Select'),
        ),
      ],
    );
  }
}