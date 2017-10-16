note
	description: "A Discord Gateway to access the server"
	author: "Louis Marchand"
	date: "Sun, 15 Oct 2017 00:23:01 +0000"
	revision: "0.1"

class
	DISCORD_GATEWAY

create
	make

feature {NONE} -- Initialization

	make(a_config:DISCORD_CONFIG; a_token, a_url:READABLE_STRING_8)
			-- Initialization of `Current' using `a_url' as `socket' url connection
			-- and using `a_config' to initializing `a_url' variables.
			-- Assign `token' with the value of `a_token'
		do
			create socket.make (a_url + "/?v=" + a_config.api_protocol_version.out + "&encoding=" + a_config.api_encoding)
			config := a_config
			token := a_token
			create message_create_actions
			socket.open_actions.extend (agent on_connect)
			socket.text_message_actions.extend (agent on_text_message)
			socket.close_actions.extend (agent on_close)
			socket.error_actions.extend (agent on_error)
		end

feature -- Access

	launch
			-- Execute the main loop of `Current'
		do
			socket.execute
		end

	message_create_actions:ACTION_SEQUENCE[TUPLE[user, message:READABLE_STRING_GENERAL]]
			-- When `Current' received a message

feature {NONE} -- Implementation

	config:DISCORD_CONFIG
			-- The Configuration of the discord library

	token:READABLE_STRING_8
			-- The token of the presently connect client.

	socket:DISCORD_WEB_SOCKET
			-- Used to communcate with the server

	on_connect(a_message:STRING)
			-- When the `socket' successfully connected
		do
			print("Gatway connected%N")
		end

	on_text_message(a_message:STRING)
			-- When the `socket' received a message
		local
			l_json_parser:JSON_PARSER
			l_opcode:INTEGER_64
		do
			-- print(a_message + "%N")
			create l_json_parser.make_with_string (a_message)
			l_json_parser.parse_content
			if
				attached {JSON_OBJECT} l_json_parser.parsed_json_value as la_json_object and then
				attached {JSON_NUMBER} la_json_object.item("op") as la_opcode and then la_opcode.is_integer
			then
				l_opcode := la_opcode.integer_64_item
				if l_opcode = opcodes.Hello and attached {JSON_OBJECT} la_json_object.item("d") as la_event_data then
					manage_hello(la_event_data)
				elseif l_opcode = opcodes.Heartbeat_ack then
					send_identify
				elseif
					l_opcode = opcodes.Dispatch and
					attached {JSON_OBJECT} la_json_object.item("d") as la_event_data and
					attached {JSON_NUMBER} la_json_object.item("s") as la_sequence and then la_sequence.is_integer and
					attached {JSON_STRING} la_json_object.item("t") as la_event_type
				then
					create last_sequence.put (la_sequence.integer_64_item)
					manage_dispatch(la_event_type.unescaped_string_8, la_event_data)
				else
					print("Error: Gateway opcode not valid (" + l_opcode.out + ").%N")
				end
			else
				print("Error: Invalid json or gateway opcode not found.%N")
				print(a_message + "%N")
			end
		end

	manage_hello(a_json_object:JSON_OBJECT)
			-- Manage the "Hello" gateway message from the server
		local
			l_env:EXECUTION_ENVIRONMENT
		do
			if attached {JSON_NUMBER} a_json_object.item("heartbeat_interval") as la_heartbeat_interval and then la_heartbeat_interval.is_integer then
				send_heartbeat
			end
		end

	send_heartbeat
			-- Send the "heartbeat" to the server (to keep the connexion alive)
			-- Must be used once every `heartbeat_interval' milliecond (ToDo)
		local
			l_json_root:JSON_OBJECT
			l_json_op:JSON_NUMBER
			l_json_d:JSON_VALUE
		do
			create l_json_root.make_with_capacity (2)
			create l_json_op.make_integer (opcodes.Heartbeat)
			if attached last_sequence as la_sequence then
				create {JSON_NUMBER}l_json_d.make_integer (la_sequence.item)
			else
				create {JSON_NULL}l_json_d
			end
			l_json_root.put (l_json_op, "op")
			l_json_root.put (l_json_d, "d")
			socket.send (l_json_root.representation)
		end

	platform_name:STRING
			-- Get the name of the platform of the client PC OS
		local
			l_platform:PLATFORM
		do
			create l_platform
			if l_platform.is_windows then
				Result := "Windows"
			elseif l_platform.is_mac then
				Result := "MacOSX"
			elseif l_platform.is_unix then
				Result := "Unix"
			elseif l_platform.is_vms then
				Result := "VMS"
			elseif l_platform.is_vxworks then
				Result := "VXWorks"
			else
				Result := "Unknown"
			end
		end

	identify_properties:JSON_OBJECT
			-- Create the "properties" section of the resulting `send_identify' json message
		do
			create Result.make_with_capacity(3)
			Result.put (create {JSON_STRING}.make_from_string (platform_name), "$os")
			Result.put (create {JSON_STRING}.make_from_string (config.Library_name), "$browser")
			Result.put (create {JSON_STRING}.make_from_string (config.Library_name), "$device")
		end

	identify_presence:JSON_OBJECT
			-- Create the "presence" section of the resulting `send_identify' json message
		do
			create Result.make_with_capacity(4)
			Result.put (create {JSON_NULL}, "since")
			Result.put (create {JSON_NULL}, "game")
			Result.put (create {JSON_STRING}.make_from_string ("online"), "status")
			Result.put (create {JSON_BOOLEAN}.make_false, "afk")
		end

	send_identify
			-- Send the identification message to the server
		local
			l_json_root, l_json_identify:JSON_OBJECT
			l_shard:JSON_ARRAY
		do
			create l_json_root.make_with_capacity (2)
			l_json_root.put (create {JSON_NUMBER}.make_integer (opcodes.Identify), "op")
			create l_json_identify.make_with_capacity (6)
			l_json_identify.put (create {JSON_STRING}.make_from_string (token), "token")
			l_json_identify.put (identify_properties, "properties")
			l_json_identify.put (create {JSON_BOOLEAN}.make_false, "compress")
			l_json_identify.put (create {JSON_NUMBER}.make_integer (250), "large_threshold")
			create l_shard.make (2)
			l_shard.add (create {JSON_NUMBER}.make_integer (0))
			l_shard.add (create {JSON_NUMBER}.make_integer (1))
			l_json_identify.put (l_shard, "shard")
			l_json_identify.put (identify_presence, "presence")
			l_json_root.put (l_json_identify, "d")
			socket.send (l_json_root.representation)
		end

	manage_dispatch(a_event_type:READABLE_STRING_8; a_event_data:JSON_OBJECT)
			-- Manage every event. The type of the event (in text) is in `a_event_type'
			-- and the data is on `a_event_data'
		do
			if a_event_type.as_upper ~ "MESSAGE_CREATE" then
				if
					attached {JSON_STRING} a_event_data.item ("content") as la_message and
					attached {JSON_OBJECT} a_event_data.item ("author") as la_author and then
					attached {JSON_STRING} la_author.item ("username") as la_username
				then
					message_create_actions.call (la_username.unescaped_string_8, la_message.unescaped_string_32)
				end
			end
		end

	on_error(a_error:STRING)
			-- When there is an error in the `socket'
		do
			print("Error: " + a_error + "%N")
		end

	on_close(a_code:INTEGER; a_reason:STRING)
			-- When the `socket' is closed
		do
			print("The gateway has closed with code " + a_code.out + " : " + a_reason + "%N")
		end

	heartbeat_interval:INTEGER_64
			-- The interval (in milliseconds) the client should heartbeat

	last_sequence:detachable CELL[INTEGER_64]
			-- The last sequence number "s" received from the gateway server

	opcodes:DISCORD_GATEWAY_OPCODES
			-- Every Opcodes of gateways
		once
			create Result
		end

end
