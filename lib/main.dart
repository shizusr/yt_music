import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(YTDownloaderApp());
}

class YTDownloaderApp extends StatefulWidget {
  @override
  _YTDownloaderAppState createState() => _YTDownloaderAppState();
}

class _YTDownloaderAppState extends State<YTDownloaderApp> {
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    });
  }

  Future<void> _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube to MP3 Downloader',
      theme: _isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
      home: DownloaderScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleTheme,
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF6AE8FF),
        secondary: Color(0xFFA78BFA),
        surface: Color(0xFF1E293B),
        background: Color(0xFF0F172A),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Color(0xFF1E293B),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF334155)),
        ),
        filled: true,
        fillColor: Color(0xFF1E293B),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6AE8FF),
        foregroundColor: Color(0xFF0F172A),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData.light().copyWith(
      colorScheme: ColorScheme.light(
        primary: Color(0xFF3B82F6),
        secondary: Color(0xFF8B5CF6),
        surface: Colors.white,
        background: Color(0xFFF8FAFC),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF3B82F6),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class DownloaderScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const DownloaderScreen({
    required this.isDarkMode,
    required this.onThemeChanged,
  });

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
  bool _showMusicPanel = false;
  bool _showLogsPanel = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _currentlyPlayingIndex;
  PlayerState _playerState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    _loadSavedDirectory();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _urlsController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDir = prefs.getString('downloadDirectory');

    if (savedDir != null && await Directory(savedDir).exists()) {
      setState(() {
        _downloadDirectory = savedDir;
      });
    } else {
      Directory dir = await getApplicationDocumentsDirectory();
      setState(() {
        _downloadDirectory = dir.path;
      });
    }
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
        isDarkMode: widget.isDarkMode,
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

  Future<void> _playMusic(int index) async {
    if (_currentlyPlayingIndex == index && _playerState == PlayerState.playing) {
      await _audioPlayer.pause();
      setState(() {
        _playerState = PlayerState.paused;
      });
      return;
    }

    final file = _musicFiles[index];
    try {
      await _audioPlayer.play(DeviceFileSource(file.path));
      setState(() {
        _currentlyPlayingIndex = index;
        _playerState = PlayerState.playing;
      });
    } catch (e) {
      _log('❌ Playback error: ${e.toString()}');
    }
  }

  Future<void> _stopMusic() async {
    await _audioPlayer.stop();
    setState(() {
      _currentlyPlayingIndex = null;
      _playerState = PlayerState.stopped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube ➤ MP3 Bulk Downloader'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.onThemeChanged(!widget.isDarkMode),
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: Icon(Icons.music_note),
            onPressed: () {
              _refreshMusicFiles();
              setState(() => _showMusicPanel = !_showMusicPanel);
            },
            tooltip: 'Toggle music panel',
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              setState(() => _showLogsPanel = !_showLogsPanel);
            },
            tooltip: 'Toggle logs panel',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Download location card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.folder, color: theme.colorScheme.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Download Location',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          Text(
                            _downloadDirectory,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: _isDownloading ? null : _changeDownloadDirectory,
                      tooltip: 'Change directory',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // URL input field
            Text(
              'YouTube URLs (one per line)',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            SizedBox(height: 4),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _urlsController,
                decoration: InputDecoration(
                  hintText: 'Paste YouTube links here...',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(fontSize: 14),
              ),
            ),
            SizedBox(height: 12),

            // Compact download button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _isDownloading ? null : _downloadAll,
                icon: _isDownloading
                    ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Icon(Icons.download, size: 20),
                label: Text(_isDownloading ? 'Downloading...' : 'Download'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Music files panel
            if (_showMusicPanel) ...[
              Row(
                children: [
                  Text(
                    'Your Music Files',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_currentlyPlayingIndex != null) ...[
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _stopMusic,
                      icon: Icon(Icons.stop, size: 18),
                      label: Text('Stop'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        backgroundColor: Colors.redAccent,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 8),
              Expanded(
                flex: 3,
                child: Card(
                  child: _musicFiles.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.music_off, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No MP3 files found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    controller: _scrollController,
                    itemCount: _musicFiles.length,
                    itemBuilder: (context, index) {
                      final file = _musicFiles[index];
                      return ListTile(
                        leading: Icon(
                          Icons.music_note,
                          color: _currentlyPlayingIndex == index
                              ? theme.colorScheme.primary
                              : theme.iconTheme.color,
                        ),
                        title: Text(
                          path.basenameWithoutExtension(file.path),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _currentlyPlayingIndex == index
                                ? theme.colorScheme.primary
                                : theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        subtitle: Text(
                          '${(File(file.path).lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: _currentlyPlayingIndex == index &&
                              _playerState == PlayerState.playing
                              ? Icon(Icons.pause)
                              : Icon(Icons.play_arrow),
                          onPressed: () => _playMusic(index),
                        ),
                        onTap: () => _playMusic(index),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],

            // Floating logs panel
            if (_showLogsPanel) ...[
              Expanded(
                child: Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Download Logs',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => setState(() => _showLogsPanel = false),
                              tooltip: 'Hide logs',
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1),
                      Expanded(
                        child: _logs.isEmpty
                            ? Center(
                          child: Text(
                            'No logs available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                            : ListView.builder(
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Text(
                                _logs[index],
                                style: TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DirectoryPickerDialog extends StatefulWidget {
  final String initialDirectory;
  final bool isDarkMode;

  const DirectoryPickerDialog({
    required this.initialDirectory,
    required this.isDarkMode,
  });

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
    _currentPath = widget.initialDirectory;
    _initializeDirectory();
  }

  Future<void> _initializeDirectory() async {
    setState(() => _isLoading = true);
    try {
      if (!await Directory(_currentPath).exists()) {
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
    final theme = Theme.of(context);
    final isDark = widget.isDarkMode;

    return AlertDialog(
      backgroundColor: isDark ? Color(0xFF1E293B) : Colors.white,
      title: Text(
        'Select Download Directory',
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      content: Container(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                  onPressed: _canGoBack ? _goBack : null,
                  tooltip: 'Back',
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward, color: isDark ? Colors.white : Colors.black),
                  onPressed: _canGoForward ? _goForward : null,
                  tooltip: 'Forward',
                ),
                IconButton(
                  icon: Icon(Icons.arrow_upward, color: isDark ? Colors.white : Colors.black),
                  onPressed: _goUp,
                  tooltip: 'Up',
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      _currentPath,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Divider(color: isDark ? Colors.white24 : Colors.black12),
            Expanded(
              child: _isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? Colors.blueAccent : Colors.blue,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  final entity = _contents[index];
                  final isDirectory = entity is Directory;
                  return ListTile(
                    leading: Icon(
                      isDirectory ? Icons.folder : Icons.insert_drive_file,
                      color: isDirectory
                          ? Colors.amber
                          : (isDark ? Colors.white70 : Colors.black54),
                    ),
                    title: Text(
                      path.basename(entity.path),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
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
          child: Text(
            'Cancel',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _currentPath),
          child: Text(
            'Select',
            style: TextStyle(color: isDark ? Colors.blueAccent : Colors.blue),
          ),
        ),
      ],
    );
  }
}