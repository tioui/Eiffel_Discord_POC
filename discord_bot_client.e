note
	description: "A discord bot client"
	author: "Louis Marchand"
	date: "Fri, 13 Oct 2017 19:58:59 +0000"
	revision: "0.1"

class
	DISCORD_BOT_CLIENT

inherit
	DISCORD_CLIENT
		rename
			login as login_client
		end

create
	default_create,
	make_from_config

feature -- Access

	login(a_token:READABLE_STRING_8)
			-- -- Log `Current' in using `a_token' as connection token
		do
			login_client("Bot", a_token)
		end

feature {NONE} -- Implementation

	gateway_sufix:STRING = "/bot"
			-- <Precursor>

end
