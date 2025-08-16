🚀 Getting Started
Prerequisites

    Flutter SDK (v3.8.1 or higher)

    yt-dlp (Latest version recommended)

    FFmpeg (For audio conversion)

Installation

    Clone the repository:
    bash

git clone https://github.com/shizusr/yt_music.git
cd yt-mp3-downloader

Install dependencies:
bash

flutter pub get

Run the application:
bash

    flutter run

🛠️ Usage

    Launch the application

    Paste YouTube URLs (one per line) in the input field

    Click "Download all as MP3"

    Monitor progress in the log window

    Find your MP3 files in ~/Music/ directory by default

Example Input:
text

https://www.youtube.com/watch?v=dQw4w9WgXcQ
https://www.youtube.com/watch?v=9bZkp7q19f0
https://www.youtube.com/watch?v=JGwWNGJdvx8

⚙️ Configuration

Modify the output directory or format by editing the Process.run command in main.dart:
dart

final result = await Process.run('yt-dlp', [
'--extract-audio',
'--audio-format',
'mp3',
'-o',
'~/Music/%(title)s.%(ext)s', // Modify this path as needed
url,
]);