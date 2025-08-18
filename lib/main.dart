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
      theme: _isDarkMode ? _buildGloomyPurpleTheme() : _buildModernLightTheme(),
      home: DownloaderScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleTheme,
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildGloomyPurpleTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Color(0xFF121212),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Color(0xFF1E1E1E),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 2,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFFBB86FC),
        ),
        iconTheme: IconThemeData(
          color: Color(0xFFBB86FC),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFBB86FC),
        foregroundColor: Colors.black,
      ),
      textTheme: ThemeData.dark().textTheme.copyWith(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        titleMedium: TextStyle(color: Color(0xFFBB86FC)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFBB86FC)),
        ),
      ),
    );
  }

  ThemeData _buildModernLightTheme() {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: Color(0xFFF5F5F5),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        iconTheme: IconThemeData(
          color: Color(0xFF7C4DFF),
        ),
      ),
      textTheme: ThemeData.light().textTheme.copyWith(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        titleMedium: TextStyle(color: Color(0xFF7C4DFF)),
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
  double _volume = 1.0;
  double _playbackSpeed = 1.0;
  Duration? _currentDuration;
  bool _showVolumeSlider = false;

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
    _setupAudioPlayerListeners();
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() => _playerState = state);
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _currentDuration = duration);
    });
    _audioPlayer.onPositionChanged.listen((_) => setState(() {}));
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _downloadDirectory = prefs.getString('downloadDirectory') ??
          (Platform.isWindows ? 'C:\\Music' : '${Directory.current.path}/Music');
      _showMusicPanel = prefs.getBool('showMusicPanel') ?? false;
      _showLogsPanel = prefs.getBool('showLogsPanel') ?? false;
    });

    if (!await Directory(_downloadDirectory).exists()) {
      await Directory(_downloadDirectory).create(recursive: true);
    }
    _refreshMusicFiles();
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  Future<void> _saveDirectory(String path) async {
    setState(() => _downloadDirectory = path);
    await _savePreference('downloadDirectory', path);
    _refreshMusicFiles();
  }

  Future<void> _refreshMusicFiles() async {
    final dir = Directory(_downloadDirectory);
    if (await dir.exists()) {
      final files = await dir.list().toList();
      setState(() {
        _musicFiles = files.where((file) => path.extension(file.path).toLowerCase() == '.mp3').toList();
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
      await _saveDirectory(newDir);
    }
  }

  void _log(String message) {
    setState(() => _logs.add(message));
  }

  Future<void> _downloadAll() async {
    final rawInput = _urlsController.text.trim();
    if (rawInput.isEmpty) {
      _log('⛔️ No URLs provided');
      return;
    }

    final urls = rawInput.split('\n').map((url) => url.trim()).where((url) => url.isNotEmpty).toList();
    if (urls.isEmpty) {
      _log('⛔️ Invalid input');
      return;
    }

    setState(() {
      _isDownloading = true;
      _logs.clear();
    });

    for (var url in urls) {
      await _downloadSingle(url);
    }

    setState(() => _isDownloading = false);
    _log('🏁 All downloads complete!');
  }

  Future<void> _downloadSingle(String url) async {
    _log('⬇️ Downloading: $url');
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download completed: $url')),
        );
        await _refreshMusicFiles();
      } else {
        _log('❌ Error: $url\n${result.stderr}');
      }
    } catch (e) {
      _log('❌ System error: $e');
    }
  }

  Future<void> _playMusic(int index) async {
    if (_currentlyPlayingIndex == index && _playerState == PlayerState.playing) {
      await _audioPlayer.pause();
      setState(() => _playerState = PlayerState.paused);
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
      _log('❌ Playback error: $e');
    }
  }

  Future<void> _stopMusic() async {
    await _audioPlayer.stop();
    setState(() {
      _currentlyPlayingIndex = null;
      _playerState = PlayerState.stopped;
    });
  }

  Widget _buildPlayerControls() {
    return Column(
      children: [
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              StreamBuilder<Duration>(
                stream: _audioPlayer.onPositionChanged,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = _currentDuration ?? Duration.zero;

                  // Проверяем, что продолжительность больше 0 перед отображением слайдера
                  if (duration.inSeconds <= 0) {
                    return SizedBox(); // Возвращаем пустой виджет, если продолжительность неизвестна
                  }

                  return Row(
                    children: [
                      Text(
                        _formatDuration(position),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Slider(
                            value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                            min: 0.0,
                            max: duration.inSeconds.toDouble(),
                            onChangeEnd: (value) {
                              _audioPlayer.seek(Duration(seconds: value.toInt()));
                            },
                            onChanged: (double value) {},
                          ),
                        ),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous),
                      onPressed: () {
                        if (_currentlyPlayingIndex != null && _currentlyPlayingIndex! > 0) {
                          _playMusic(_currentlyPlayingIndex! - 1);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _playerState == PlayerState.playing ? Icons.pause : Icons.play_arrow,
                        size: 32,
                      ),
                      onPressed: () {
                        if (_currentlyPlayingIndex != null) {
                          _playMusic(_currentlyPlayingIndex!);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next),
                      onPressed: () {
                        if (_currentlyPlayingIndex != null && _currentlyPlayingIndex! < _musicFiles.length - 1) {
                          _playMusic(_currentlyPlayingIndex! + 1);
                        }
                      },
                    ),
                    SizedBox(width: 16),
                    MouseRegion(
                      onEnter: (_) => setState(() => _showVolumeSlider = true),
                      onExit: (_) => setState(() => _showVolumeSlider = false),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _volume == 0
                                  ? Icons.volume_off
                                  : _volume < 0.5
                                  ? Icons.volume_down
                                  : Icons.volume_up,
                              size: 20,
                            ),
                            onPressed: () {
                              final newVol = _volume > 0 ? 0.0 : 1.0;
                              setState(() => _volume = newVol);
                              _audioPlayer.setVolume(newVol);
                            },
                          ),
                          AnimatedContainer(
                            width: _showVolumeSlider ? 100 : 0,
                            duration: Duration(milliseconds: 200),
                            child: _showVolumeSlider
                                ? SizedBox(
                              width: 100,
                              child: Slider(
                                value: _volume,
                                min: 0,
                                max: 1,
                                onChanged: (value) {
                                  setState(() => _volume = value);
                                  _audioPlayer.setVolume(value);
                                },
                              ),
                            )
                                : SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  void _toggleMusicPanel() async {
    final newValue = !_showMusicPanel;
    setState(() => _showMusicPanel = newValue);
    if (newValue) await _refreshMusicFiles();
    await _savePreference('showMusicPanel', newValue);
  }

  void _toggleLogsPanel() async {
    final newValue = !_showLogsPanel;
    setState(() => _showLogsPanel = newValue);
    await _savePreference('showLogsPanel', newValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube ➤ MP3 Bulk Downloader'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Верхняя часть (форма ввода и кнопки)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: TextField(
                    controller: _urlsController,
                    decoration: InputDecoration(
                      hintText: 'Paste YouTube links here...',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () => _urlsController.clear(),
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _toggleMusicPanel,
                        icon: Icon(Icons.music_note),
                        label: Text(_showMusicPanel ? 'Hide Music' : 'Show Music'),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isDownloading ? null : _downloadAll,
                        icon: _isDownloading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Icon(Icons.download),
                        label: Text(_isDownloading ? 'Downloading...' : 'Download'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),

            // Средняя часть (заголовок и плеер)
            if (_showMusicPanel) ...[
              Row(
                children: [
                  Text('Your Music Files', style: theme.textTheme.titleLarge),
                  if (_currentlyPlayingIndex != null) ...[
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _stopMusic,
                      icon: Icon(Icons.stop),
                      label: Text('Stop'),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 8),
              if (_currentlyPlayingIndex != null) _buildPlayerControls(),
              SizedBox(height: 8),
            ],

            // Нижняя часть (список песен) с Expanded
            if (_showMusicPanel)
              Expanded(
                child: Card(
                  child: _musicFiles.isEmpty
                      ? Center(child: Text('No MP3 files found'))
                      : ListView.builder(
                    itemCount: _musicFiles.length,
                    itemBuilder: (context, index) {
                      final file = _musicFiles[index];
                      return GestureDetector(
                        onTap: () => _playMusic(index),
                        onSecondaryTap: () {
                          showContextMenu(context, file);
                        },
                        child: ListTile(
                          leading: Icon(Icons.music_note),
                          title: Text(path.basenameWithoutExtension(file.path)),
                          subtitle: Text(
                            // Corrected file size calculation
                            '${(File(file.path).lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
                          ), // Subtitle's Text widget ends here
                          // Correctly placed trailing property
                          trailing: IconButton(
                            icon: Icon(Icons.folder_open),
                            onPressed: () {
                              if (Platform.isWindows) {
                                Process.run('explorer', [file.parent.path]);
                              } else if (Platform.isLinux) {
                                Process.run('xdg-open', [file.parent.path]);
                              } else if (Platform.isMacOS) {
                                Process.run('open', [file.parent.path]);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void showContextMenu(BuildContext context, FileSystemEntity file) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        Offset(0, overlay.size.height),
        Offset(overlay.size.width, overlay.size.height),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.folder_open),
            title: Text('Open containing folder'),
            onTap: () {
              Navigator.pop(context);
              if (Platform.isWindows) {
                Process.run('explorer', [file.parent.path]);
              } else if (Platform.isLinux) {
                Process.run('xdg-open', [file.parent.path]);
              } else if (Platform.isMacOS) {
                Process.run('open', [file.parent.path]);
              }
            },
          ),
        ),
      ],
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.folder),
              title: Text('Download Directory'),
              subtitle: Text(_downloadDirectory),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.pop(context);
                  _changeDownloadDirectory();
                },
              ),
            ),
            SwitchListTile(
              title: Text('Dark Theme'),
              value: widget.isDarkMode,
              onChanged: widget.onThemeChanged,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
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

  @override
  void initState() {
    super.initState();
    _currentPath = widget.initialDirectory;
    _loadDirectoryContents();
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateTo(String path) {
    setState(() => _currentPath = path);
    _loadDirectoryContents();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Directory'),
      content: Container(
        width: double.maxFinite,
        height: 400,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: _contents.length,
          itemBuilder: (context, index) {
            final entity = _contents[index];
            final isDirectory = entity is Directory;
            return ListTile(
              leading: Icon(isDirectory ? Icons.folder : Icons.insert_drive_file),
              title: Text(path.basename(entity.path)),
              onTap: isDirectory ? () => _navigateTo(entity.path) : null,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _currentPath),
          child: Text('Select'),
        ),
      ],
    );
  }
}
