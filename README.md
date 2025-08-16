# YouTube to MP3 Downloader


## Prerequisites 📋

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.8.1+)
- [yt-dlp](https://github.com/yt-dlp/yt-dlp#installation) (Latest recommended)
- [FFmpeg](https://ffmpeg.org/) (For audio conversion)

## Installation :wrench:

### 1. Clone repository
```sh
git clone https://github.com/yourusername/yt-mp3-downloader.git
cd yt-mp3-downloader
```

### 2. Install dependencies
```sh
flutter pub get
```

### 3. Run application
```sh
flutter run
```
## Usage 🎯

1. **Launch the application**  
   Run the app using `flutter run` or your preferred method

2. **Paste YouTube URLs**  
Enter one URL per line in the input field:

3. **Click "Download all as MP3"**  
The download process will begin

4. **Monitor progress**  
View real-time status in the log window

5. **Access your files**  
Downloaded MP3s will be saved to:  
`~/Music/` (Linux/Mac) or  
`%USERPROFILE%\Music\` (Windows)

### Example Input
```plaintext
https://www.youtube.com/watch?v=dQw4w9WgXcQ
https://www.youtube.com/watch?v=9bZkp7q19f0
https://www.youtube.com/watch?v=JGwWNGJdvx8
```

## Configuration ⚙️

To customize the download behavior, modify the `Process.run` command in [`lib/main.dart`](./lib/main.dart):

```dart
final result = await Process.run('yt-dlp', [
  '--extract-audio',    // Audio-only extraction
  '--audio-format',     // Output format specification
  'mp3',                // Default format (can change to opus/m4a/etc)
  '-o',                 // Output template flag
  '~/Music/%(title)s.%(ext)s', // ← Edit this path/format
  url,                  // YouTube URL variable
]);
```
