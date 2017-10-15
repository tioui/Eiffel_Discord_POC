note
	description: "A discord client"
	author: "Louis Marchand"
	date: "Fri, 13 Oct 2017 19:58:59 +0000"
	revision: "0.1"

deferred class
	DISCORD_CLIENT

inherit
	SHARED_EJSON
		redefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
			-- Initialization of `Current'
		do
			make_from_config(create {DISCORD_CONFIG})
		end

	make_from_config(a_config:DISCORD_CONFIG)
			-- Initialization of `Current' using `a_config' as `config'
		require
			Config_Is_Json: a_config.API_encoding ~ "json"
		do
			config := a_config
			create {LIBCURL_HTTP_CLIENT_SESSION}rest_session.make(config.API_url)
			rest_session.add_header ("user-agent", "DiscordBot (" + config.Library_url + ", v" + config.Library_version + ")")
			create message_create_actions
		ensure
			Config_Assign: config ~ a_config
		end

feature -- Access

	config:DISCORD_CONFIG
			-- The Configuration of the discord library

	is_logged_in:BOOLEAN
			-- The `connect' feature has been called at least once
		do
			Result := attached logged_token
		end

	login(a_token_type, a_token:READABLE_STRING_8)
			-- Log `Current' in using `a_token' with the type `a_token_type'
		require
			Token_Not_Empty: not a_token_type.is_empty and not a_token.is_empty
		do
			rest_session.add_header ("authorization", a_token_type + " " + a_token)
			logged_token := a_token
		ensure
			Is_Logged_In: is_logged_in
		end

	logged_token:detachable READABLE_STRING_8
			-- The token set by `login'

	launch
			-- Execute the connecting loop of `Current'
		local
			l_response:HTTP_CLIENT_RESPONSE
			l_json_parser:JSON_PARSER
			l_gateway:DISCORD_GATEWAY
		do
			l_response := rest_session.get ("/gateway/bot", Void)
			if attached l_response.body as la_json then
				create l_json_parser.make_with_string (la_json)
				l_json_parser.parse_content
				if
					attached {JSON_OBJECT} l_json_parser.parsed_json_value as la_json_object and then
					attached {JSON_STRING} la_json_object.item("url") as la_url and then
					attached logged_token as la_token
				then
					create l_gateway.make (config, la_token, la_url.unescaped_string_8)
					l_gateway.message_create_actions.extend (agent (a_user, a_message:READABLE_STRING_GENERAL) do message_create_actions.call (a_user, a_message) end)
					l_gateway.launch
				end
			end
		end

	message_create_actions:ACTION_SEQUENCE[TUPLE[user, message:READABLE_STRING_GENERAL]]
			-- When `Current' received a message

feature -- Implementation

	rest_session:HTTP_CLIENT_SESSION
			-- The session used to send information to the API server

invariant
	Config_Is_Json_Encoding: config.API_encoding ~ "json"
end
