# Youtube-VLC
Use youtube-dl to stream Youtube videos on VLC Media Player (any quality)
This can be used to play individual videos as well as whole playlists.

## Need

> VLC itself can get the stream URL and play the video on its own, but it chooses that stream which contains both, video as well as audio. And most of the times this is lower than the best quality available which can be disappoiniting at times.
With this configuration you can tweak the quality of the video that you want to watch on VLC which can actually be beneficial in terms of performance and power consumption and as well as provide you all the functionality that vlc offers as compared to watching videos in web browser.

## Dependency
> **[youtube-dl](https://github.com/ytdl-org/youtube-dl/)**

## Usage
- Install the latest release of youtube-dl from their repository.
- In case of windows, also add the location of youtube-dl in PATH environment variable.
- Copy the youtube-dl.lua :

	For windows
	```
	C:\Program Files\VideoLAN\VLC\lua\playlist
	```
	For linux
	```
	/usr/share/vlc/lua/playlist/
	```
- Rename or remove the existing youtube.luac so that it is not used to parse the URL.
