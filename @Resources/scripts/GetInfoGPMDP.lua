songTitleOld = nil
playStatusOld = nil

function Update()
	
	fileToRead = SELF:GetOption('FileToRead')
	
	--"title": null,
    --"artist": null,
    --"album": null,
    --"albumArt": null
	--"current": 0,
    --"total": 0
	
	local File = io.open(fileToRead)
	if not File then
		print("Unable to open Google Play Music's playback json at " .. fileToRead)
	else
		local FileContents = File:read("*all")
		File:close()
		
		local songTitle, songArtist, songAlbumArt, songLength, songPosition = nil

		--Convert JSON to lua table and set meters

		if (FileContents ~= nill) and (string.len(FileContents) > 1) then
		
			local songTitles = string.gmatch(FileContents, '"title"%b:\n')
			local songArtists = string.gmatch(FileContents, '"artist"%b:\n')
			local songAlbumArts = string.gmatch(FileContents, '"albumArt"%b:\n')
			local songPositions = string.gmatch(FileContents, '"current"%b:,\n')
			local songLengths = string.gmatch(FileContents, '"total"%b:,')
			
			for word in songTitles do songTitle=word end
			for word in songArtists do songArtist=word end
			for word in songAlbumArts do songAlbumArt=word end
			for word in songLengths do songLength=word end
			for word in songPositions do songPosition=word end
		
			songTitle = string.sub(songTitle, string.find(songTitle, ":")+2, -3)
			songArtist = string.sub(songArtist, string.find(songArtist, ":")+2, -3)
			songAlbumArt = string.sub(songAlbumArt, string.find(songAlbumArt, ":")+2, -4)
			songPosition = string.sub(songPosition, string.find(songPosition, ":")+2, -3) / 1000
			songLength = string.sub(songLength, string.find(songLength, ":")+2, -3) / 1000
			
			local songPositionMin = math.floor(songPosition / 60)
			local songPositionSec = math.floor(songPosition % 60 + .5)
			
			local songLengthMin = math.floor(songLength / 60)
			local songLengthSec = math.floor(songLength % 60 + .5)
			
			if(string.len(songPositionMin) < 2) then songPositionMin = "0" .. songPositionMin end
			if(string.len(songPositionSec) < 2) then songPositionSec = "0" .. songPositionSec end
			if(string.len(songLengthMin) < 2) then songLengthMin = "0" .. songLengthMin end
			if(string.len(songLengthSec) < 2) then songLengthSec = "0" .. songLengthSec end
		
			songPosition = songPositionMin .. ":" .. songPositionSec
			songLength = songLengthMin .. ":" .. songLengthSec
			
			--print(string.sub(songTitle, 2, -2))
			--print(string.sub(songArtist, 2, -2))
			--print(songPosition)
			--print(songLength)
			--OnChangeAction=[!CommandMeasure DoWriteUpdate "Stop 1"][!CommandMeasure DoWriteUpdate "Execute 1"]
			
			if(songTitleOld == nil) or (songTitle ~= songTitleOld) then
				songTitleOld = songTitle
				if(songTitle ~= "null") then
					SKIN:Bang('!SetVariable', 'GPMSongTitle', string.sub(songTitle, 2, -2))
					SKIN:Bang('!SetVariable', 'GPMSongArtist', string.sub(songArtist, 2, -2))
					SKIN:Bang('!SetVariable', 'GPMSongPosition', songPosition)
					SKIN:Bang('!SetVariable', 'GPMSongLength', songLength)
					if(string.find(songAlbumArt, "default") ~= nil) then
						SKIN:Bang('!SetVariable', 'GPMSongAlbumArt', "")
						SKIN:Bang('!SetOption', 'MeasureAlbumArtGPMDP', 'OnChangeAction', '[!CommandMeasure DoWriteUpdate "Stop 1"][!CommandMeasure DoWriteUpdate "Execute 1"]')
						SKIN:Bang('!SetOption', 'MeasureAlbumArtGPMDP', 'String', "")
						SKIN:Bang('!UpdateMeasureGroup', 'AlbumArtUpdate')
						--print("Using fallback info")	
						SKIN:Bang('!UpdateMeterGroup', 'CoverGroup')						
					else
						SKIN:Bang('!SetVariable', 'GPMSongAlbumArt', string.sub(songAlbumArt, 2, -7))	
						SKIN:Bang('!SetOption', 'MeasureAlbumChangedNotifyGPMDP', 'url', string.sub(songAlbumArt, 2, -7))
						SKIN:Bang('!CommandMeasure', 'MeasureAlbumChangedNotifyGPMDP', 'Update')
						--print(string.sub(songAlbumArt, 2, -7))	
						SKIN:Bang('!SetOption', 'MeasureAlbumArtGPMDP', 'OnChangeAction', '')
						SKIN:Bang('!SetOption', 'MeasureAlbumArtGPMDP', 'String', SKIN:GetVariable("CURRENTPATH") .. "DownloadFile\\image1.jpg")
						SKIN:Bang('!UpdateMeasureGroup', 'AlbumArtUpdate')
					end
					
					SKIN:Bang('!SetOptionGroup', 'TitleGroup', 'DynamicVariables', '0')
					SKIN:Bang('!SetOptionGroup', 'ArtistGroup', 'DynamicVariables', '0')
					--SKIN:Bang('!SetOptionGroup', 'CoverGroup', 'DynamicVariables', '0')
					SKIN:Bang('!SetOptionGroup', 'MediaPosition', 'DynamicVariables', '0')
					SKIN:Bang('!SetOptionGroup', 'MediaDuration', 'DynamicVariables', '0')
					
					--SKIN:Bang('!UpdateMeasureGroup', 'AlbumArtUpdate')
				else
					
					SKIN:Bang('!SetVariable', 'GPMSongTitle', SKIN:GetVariable("NoTrackNameText", "N/A"))
					SKIN:Bang('!SetVariable', 'GPMSongArtist', SKIN:GetVariable("NoTrackNameText", "N/A"))
					SKIN:Bang('!SetVariable', 'GPMSongAlbumArt', "")
					SKIN:Bang('!SetVariable', 'GPMSongPosition', "00:00")
					SKIN:Bang('!SetVariable', 'GPMSongLength', "00:00")
					
					SKIN:Bang('!SetOptionGroup', 'TitleGroup', 'DynamicVariables', '0')
					SKIN:Bang('!SetOptionGroup', 'ArtistGroup', 'DynamicVariables', '0')
					--SKIN:Bang('!SetOptionGroup', 'CoverGroup', 'DynamicVariables', '0')
					SKIN:Bang('!SetOptionGroup', 'MediaPosition', 'DynamicVariables', '0')
					SKIN:Bang('!SetOptionGroup', 'MediaDuration', 'DynamicVariables', '0')

					SKIN:Bang('!SetOption', 'MeasureAlbumArtGPMDP', 'OnChangeAction', '[!CommandMeasure DoWriteUpdate "Stop 1"][!CommandMeasure DoWriteUpdate "Execute 1"]')
					SKIN:Bang('!SetOption', 'MeasureAlbumArtGPMDP', 'String', "")
					--print("Using fallback info")	
					SKIN:Bang('!UpdateMeasureGroup', 'AlbumArtUpdate')
					SKIN:Bang('!UpdateMeterGroup', 'CoverGroup')
				end
			else
				SKIN:Bang('!SetVariable', 'GPMSongPosition', songPosition)	
				SKIN:Bang('!SetOptionGroup', 'MediaPosition', 'DynamicVariables', '0')		
			end
		else
			--print("Google Play Music's json file wsas empty. Did you turn on the external API?")
		end
	end
end
