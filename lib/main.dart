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
    );
  }

  ThemeData _buildGloomyPurpleTheme() {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        primary: Color(0xFFBB86FC),  // Light purple
        primaryContainer: Color(0xFF3700B3),  // Deep purple
        secondary: Color(0xFF03DAC6),  // Teal accent
        secondaryContainer: Color(0xFF018786),  // Darker teal
        surface: Color(0xFF121212),  // Dark surface
        background: Color(0xFF121212),  // Dark background
        error: Color(0xFFCF6679),  // Error color
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.black,
      ),
      scaffoldBackgroundColor: Color(0xFF121212),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Color(0xFF1E1E1E),  // Slightly lighter than background
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 2,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFFBB86FC),  // Purple text
        ),
        iconTheme: IconThemeData(
          color: Color(0xFFBB86FC),  // Purple icons
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFBB86FC),  // Purple FAB
        foregroundColor: Colors.black,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: Colors.white),
        displayMedium: TextStyle(color: Colors.white),
        displaySmall: TextStyle(color: Colors.white),
        headlineMedium: TextStyle(color: Colors.white),
        headlineSmall: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Color(0xFFBB86FC)),  // Purple titles
        titleSmall: TextStyle(color: Colors.white70),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        bodySmall: TextStyle(color: Colors.white54),
        labelLarge: TextStyle(color: Colors.black),  // For buttons
        labelSmall: TextStyle(color: Colors.white70),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFBB86FC)),  // Purple border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFBB86FC).withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFBB86FC), width: 2),
        ),
        labelStyle: TextStyle(color: Color(0xFFBB86FC)),  // Purple labels
        hintStyle: TextStyle(color: Colors.white54),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFBB86FC),  // Purple button
          foregroundColor: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Color(0xFFBB86FC),  // Purple text
        ),
      ),
      iconTheme: IconThemeData(
        color: Color(0xFFBB86FC),  // Purple icons
      ),
      dividerTheme: DividerThemeData(
        color: Color(0xFFBB86FC).withOpacity(0.2),  // Subtle purple divider
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: Color(0xFFBB86FC),  // Purple icons
        textColor: Colors.white,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return Color(0xFFBB86FC);  // Purple when on
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return Color(0xFFBB86FC).withOpacity(0.5);  // Purple track when on
          }
          return Colors.grey.withOpacity(0.5);
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: Color(0xFFBB86FC),  // Purple loading indicators
      ),
    );
  }

  ThemeData _buildModernLightTheme() {
    return ThemeData.light().copyWith(
      colorScheme: ColorScheme.light(
        primary: Color(0xFF7C4DFF),  // Deep purple
        primaryContainer: Color(0xFF651FFF),  // Darker purple
        secondary: Color(0xFF00B0FF),  // Bright blue accent
        secondaryContainer: Color(0xFF0081CB),  // Darker blue
        surface: Colors.white,
        background: Color(0xFFF5F5F5),  // Very light grey background
        error: Color(0xFFE53935),  // Red for errors
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
        onBackground: Colors.black,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: Color(0xFFF5F5F5),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        surfaceTintColor: Colors.white,
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
          color: Color(0xFF7C4DFF),  // Purple icons
        ),
        actionsIconTheme: IconThemeData(
          color: Color(0xFF7C4DFF),  // Purple action icons
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF7C4DFF),  // Purple FAB
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
        displayMedium: TextStyle(color: Colors.black87),
        displaySmall: TextStyle(color: Colors.black87),
        headlineMedium: TextStyle(color: Colors.black87),
        headlineSmall: TextStyle(color: Colors.black87),
        titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: Color(0xFF7C4DFF)),  // Purple titles
        titleSmall: TextStyle(color: Colors.black54),
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        bodySmall: TextStyle(color: Colors.black54),
        labelLarge: TextStyle(color: Colors.white),  // For buttons
        labelSmall: TextStyle(color: Colors.black54),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF7C4DFF), width: 2),
        ),
        labelStyle: TextStyle(color: Colors.black54),
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF7C4DFF),  // Purple button
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Color(0xFF7C4DFF),  // Purple text
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(0xFF7C4DFF),  // Purple outline
          side: BorderSide(color: Color(0xFF7C4DFF)),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: Color(0xFF7C4DFF),  // Purple icons
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,  // Very light grey divider
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: Color(0xFF7C4DFF),  // Purple icons
        textColor: Colors.black87,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return Color(0xFF7C4DFF);  // Purple when on
          }
          return Colors.grey.shade400;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return Color(0xFF7C4DFF).withOpacity(0.5);  // Purple track when on
          }
          return Colors.grey.shade400.withOpacity(0.5);
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: Color(0xFF7C4DFF),  // Purple loading indicators
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: Color(0xFF7C4DFF),
        secondarySelectedColor: Color(0xFF7C4DFF),
        labelStyle: TextStyle(color: Colors.black87),
        secondaryLabelStyle: TextStyle(color: Colors.white),
        brightness: Brightness.light,
        padding: EdgeInsets.all(4),
        shape: StadiumBorder(),
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
    _loadSavedPreferences();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });
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
    setState(() {
      _downloadDirectory = path;
    });
    await _savePreference('downloadDirectory', path);
    _refreshMusicFiles();
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
      await _saveDirectory(newDir);
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

  void _toggleMusicPanel() async {
    final newValue = !_showMusicPanel;
    setState(() {
      _showMusicPanel = newValue;
    });
    if (newValue) {
      _refreshMusicFiles();
    }
    await _savePreference('showMusicPanel', newValue);
  }

  void _toggleLogsPanel() async {
    final newValue = !_showLogsPanel;
    setState(() {
      _showLogsPanel = newValue;
    });
    await _savePreference('showLogsPanel', newValue);
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Preferences'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // General Section
                  Text(
                    'General',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Theme Selection
                  Text('App Theme', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      ChoiceChip(
                        label: Text('Light'),
                        selected: !widget.isDarkMode,
                        onSelected: (selected) {
                          if (selected) widget.onThemeChanged(false);
                        },
                      ),
                      SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('Dark'),
                        selected: widget.isDarkMode,
                        onSelected: (selected) {
                          if (selected) widget.onThemeChanged(true);
                        },
                      ),
                      SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('System'),
                        selected: false,
                        onSelected: (selected) {
                          // You would implement system theme detection here
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Download Settings
                  Text('Download Settings', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
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
                  SizedBox(height: 16),

                  // Audio Quality
                  Text('Audio Quality', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: 'high', // Default value
                    items: [
                      DropdownMenuItem(value: 'low', child: Text('Low (96kbps)')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium (128kbps)')),
                      DropdownMenuItem(value: 'high', child: Text('High (192kbps)')),
                      DropdownMenuItem(value: 'best', child: Text('Best (320kbps)')),
                    ],
                    onChanged: (value) {
                      // Save quality preference
                    },
                  ),
                  SizedBox(height: 16),

                  // Advanced Settings
                  Text('Advanced', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  SwitchListTile(
                    title: Text('Show weekly tips'),
                    value: true,
                    onChanged: (value) {},
                  ),
                  SwitchListTile(
                    title: Text('Send usage statistics'),
                    subtitle: Text('Help improve the app by sending anonymous usage data'),
                    value: true,
                    onChanged: (value) {},
                  ),
                  SwitchListTile(
                    title: Text('Auto-update check'),
                    value: true,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Save all settings
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube ➤ MP3 Bulk Downloader'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _toggleMusicPanel,
                        icon: Icon(Icons.music_note),
                        label: Text(_showMusicPanel ? 'Hide Music' : 'Show Music'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showSettingsDialog,
                        icon: Icon(Icons.settings),
                        label: Text('Settings'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
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
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                if (_showMusicPanel) ...[                    Row(
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
            onPressed: _toggleLogsPanel,
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