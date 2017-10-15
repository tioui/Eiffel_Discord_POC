note
	description: "An proof of concept using the Discord API"
	author: "Louis Marchand"
	date: "Fri, 13 Oct 2017 19:58:59 +0000"
	revision: "0.1"

class
	APPLICATION

inherit
	ARGUMENTS

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		local
			l_client:DISCORD_BOT_CLIENT
			l_test:JSON_DESERIALIZER
		do
			if attached bot_token as la_bot_token then
				create l_client
				l_client.login (la_bot_token)
				l_client.message_create_actions.extend (agent message_received)
				l_client.launch
			end
		end

	bot_token:detachable STRING_8
			-- To set your own bot token, create the file "bot_token" (without extension) and put the
			-- token in it (on the first line).
		local
			l_file:PLAIN_TEXT_FILE
		do
			create l_file.make_with_name ("bot_token")
			if l_file.exists and l_file.is_access_readable then
				l_file.open_read
				if l_file.is_readable then
					l_file.read_line
					if not l_file.last_string.is_empty then
						Result := l_file.last_string.twin
					end
				end
			end
		end

	message_received(a_user, a_message:READABLE_STRING_GENERAL)
			-- `a_message' has been received from `a_user'
		local
			l_converter:UTF_CONVERTER
			l_message:STRING
		do
			create l_converter
			l_message := l_converter.string_32_to_utf_8_string_8 (a_message.as_string_32)
			print(a_user + " has typed: " + l_message + "%N")
		end

end
