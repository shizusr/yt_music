# YouTube to MP3 Downloader

## Prerequisites 📋

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.8.1+)
- [yt-dlp](https://github.com/yt-dlp/yt-dlp#installation) (Latest recommended)
- [FFmpeg](https://ffmpeg.org/) (For audio conversion)

## Installation 🛠️

1. Clone the repository:

   git clone https://github.com/yourusername/yt-mp3-downloader.git
   cd yt-mp3-downloader

2. Install dependencies:
   
    flutter pub get

3. Run the application:

    flutter run

Usage 🎯

    Launch the application

    Paste YouTube URLs (one per line) in the input field

    Click "Download all as MP3"

    Monitor progress in the log window

    Find your MP3 files in ~/Music/ directory by default

Example Input:

https://www.youtube.com/watch?v=dQw4w9WgXcQ
https://www.youtube.com/watch?v=9bZkp7q19f0
https://www.youtube.com/watch?v=JGwWNGJdvx8

Configuration ⚙️

Modify the output directory or format by editing the Process.run command in lib/main.dart:
dart

final result = await Process.run('yt-dlp', [
  '--extract-audio',
  '--audio-format',
  'mp3',
  '-o',
  '~/Music/%(title)s.%(ext)s', // Modify this path
  url,
]);
