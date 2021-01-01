-- load additional json routines
JSON = require "dkjson"


-- preference for max quality
max_video_quality = 1080

-- vlc.msg.dbg() for testing

-- Probe function.
function probe()
	return (vlc.access == "http" or vlc.access == "https") and (string.match( vlc.path, "www.youtube.com/watch" ) or string.match( vlc.path, "www.youtube.com/playlist" ))
end

-- Parse function.
function parse()
	-- get full url
	local url = vlc.access.."://"..vlc.path
	local file = assert(io.popen('youtube-dl -j --yes-playlist "'..url..'"', 'r'))
  
	local tracks = {}

	-- for every video fetched
	while true do
	  	local output = file:read('*l')
	  	if not output then
	    	break
	  	end

	    -- decode the json-output from youtube-dl
	    local json = JSON.decode(output) 
	    if not json then
	      break
	    end

	    local video_url = nil
	    local max_video_found = 0
	    local video_format_id = ""

	    local audio_url = nil
	    local max_abr_found = 0
	    local audio_format_id = ""

    	if json.formats then
	      	for key, format in pairs(json.formats) do
	      		-- to avoid dash streams
	      		if format.fragments == nil then
		      		-- capturing video link
		        	if format.vcodec ~= (nil or "none") and format.height<=max_video_quality and format.height>=max_video_found then
		          		max_video_found = format.height
		          		video_format_id = format.format_id
		          		video_url = format.url
		          		if format.acodec ~= (nil or "none") and format.abr>max_abr_found then
		          			audio_format_id = format.format_id
		          		end
		        	end

		        	-- capturing audio link, link should contain audio, and also no video, otherwise will play a 3D file
		        	if format.acodec ~= (nil or "none") and format.abr>max_abr_found and format.vcodec == (nil or "none") then
		         		max_abr_found = format.abr
		         		audio_format_id = format.format_id
		          		audio_url = format.url
		        	end
		        -- didn't find a workaround for separate audio and video in dash streams
		        else
		        	video_url = format.url
		        	audio_url = format.url
		        	video_format_id = format.format_id
		        	audio_format_id = format.format_id
		        end
	      	end
    	end

	    if video_url then
	    	local category = nil
	    	if json.categories then
	      		category = json.categories[1]
	    	end

	    	local year = nil
	    	if json.release_year then
	      		year = json.release_year
	    	elseif json.release_date then
	      		year = string.sub(json.release_date, 1, 4)
	    	elseif json.upload_date then
	      		year = string.sub(json.upload_date, 1, 4)
	    	end

	    	local thumbnail = nil
	    	if json.thumbnails then
	      		thumbnail = json.thumbnails[#json.thumbnails].url
	    	end

	    	jsoncopy = {}
	    	for k in pairs(json) do
	      		jsoncopy[k] = tostring(json[k])
	    	end

	    	json = jsoncopy

	    	item = {
		        path         = video_url;
		        name         = json.title;
		        duration     = json.duration;

		        -- for a list of these check vlc/modules/lua/libs/sd.c
		        title        = json.track or json.title;
		        artist       = json.artist or json.creator or json.uploader or json.playlist_uploader;
		        genre        = json.genre or category;
		        copyright    = json.license;
		        album        = json.album or json.playlist_title or json.playlist;
		        tracknum     = json.track_number or json.playlist_index;
		        description  = json.description;
		        rating       = json.average_rating;
		        date         = year;
		        -- setting
		        url          = json.webpage_url or url;
		        -- language
		        -- nowplaying
		        -- publisher
		        -- encodedby
		        arturl       = json.thumbnail or thumbnail;
		        trackid      = json.track_id or json.episode_id or json.id;
		        tracktotal   = json.n_entries;
		        -- director
		        season       = json.season or json.season_number or json.season_id;
		        episode      = json.episode or json.episode_number;
		        show_name    = json.series;
		        -- actors
		        meta         = json;
		        options      = {};
			}
			if video_format_id ~= audio_format_id then
				item['options'][':input-slave'] = ":input-slave="..audio_url;
			end
	    	table.insert(tracks, item)
	    end
	end
	file:close()
	return tracks
end
