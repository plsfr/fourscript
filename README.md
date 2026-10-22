# YouTube Video Downloader

A simple YouTube video downloader built with `yt-dlp`, featuring single-video downloads and bulk downloading from text files.

## Features

- **Single video download** — download videos directly using a YouTube URL.
- **Bulk downloading** — process up to 100 YouTube links from a `.txt` file.
- **Browser cookies support** — use browser cookies to authenticate requests and access videos that require a signed-in session.
- **Custom save location** — choose where downloaded videos are stored.
- **Automatic processing** — download multiple videos sequentially without entering each URL manually.
- **Simple interface** — operate the downloader through a Windows batch script.

## Requirements

- Windows
- Python
- `yt-dlp`
- FFmpeg (recommended for media merging and post-processing)
- A supported browser with an authenticated YouTube session, if cookies are required

## Cookies

The downloader can use browser cookies to authenticate requests. This may help with videos that require a signed-in account and may reduce certain verification interruptions.

Cookies do not guarantee that CAPTCHA challenges or other YouTube restrictions will be bypassed.

Keep your cookies private. Never upload cookie files, browser session data, passwords, or authentication tokens to GitHub.

## Usage

1. Run `FourScript.bat`.
2. Paste a YouTube video URL or provide a `.txt` file containing up to 100 links.
3. Allow the script to process the downloads.
4. Find the downloaded videos in the configured output directory.

## Built With

- Python
- yt-dlp
- Windows Batch

## Disclaimer

This project is intended for personal and educational use. Users are responsible for complying with YouTube's Terms of Service and applicable copyright laws.

---

A lightweight YouTube downloader for individual videos and bulk link processing, with optional browser-cookie authentication.
