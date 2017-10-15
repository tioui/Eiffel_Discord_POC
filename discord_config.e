note
	description: "Discord API configuration"
	author: "Louis Marchand"
	date: "Fri, 13 Oct 2017 19:58:59 +0000"
	revision: "0.1"

class
	DISCORD_CONFIG

feature -- Access

	Library_name:STRING
			-- The version of the library
		once
			Result := "Discord.ecf"
		end

	Library_version:STRING
			-- The version of the library
		once
			Result := "0.1"
		end

	Library_url:STRING
			-- The URL of the library
		once
			Result := "https://github.com/ZeLarpMaster/Discord.ecf"
		end

	API_base_url:STRING
			-- The base URL used to access Discord API
		once
			Result := "https://discordapp.com/api"
		end

	API_protocol_version:INTEGER
			-- The version of the Discord API and Gateway
		once
			Result := 6
		end

	API_encoding:STRING
			-- The type of encoding used to access the API
		once
			Result := "json"
		end

	API_url:STRING
			-- The URL used to access Discord API
		once
			Result := API_base_url + "/v" + API_protocol_version.out
		end

end
