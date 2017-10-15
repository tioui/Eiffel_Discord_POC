note
	description: "A Discord Gateway to access the server"
	author: "Louis Marchand"
	date: "Sun, 15 Oct 2017 00:23:01 +0000"
	revision: "0.1"

class
	DISCORD_GATEWAY_OPCODES

feature -- Constants

	Dispatch:INTEGER_64 = 0
			-- dispatches an event (Receive)

	Heartbeat:INTEGER_64 = 1
			-- used for ping checking (Send/Receive)

	Identify:INTEGER_64 = 2
			-- used for client handshake (Send)

	Status_update:INTEGER_64 = 3
			-- used to update the client status (Send)

	Voice_state_update:INTEGER_64 = 4
			-- used to join/move/leave voice channels (Send)

	Voice_server_ping:INTEGER_64 = 5
			-- used for voice ping checking (Send)

	Resume:INTEGER_64 = 6
			-- used to resume a closed connection (Send)

	Reconnect:INTEGER_64 = 7
			-- used to tell clients to reconnect to the gateway (Receive)

	Request_guild_members:INTEGER_64 = 8
			-- used to request guild members (Send)

	Invalid_session:INTEGER_64 = 9
			-- used to notify client they have an invalid session id

	Hello:INTEGER_64 = 10
			-- sent immediately after connecting, contains heartbeat and server debug information (Receive)

	Heartbeat_ack:INTEGER_64 = 11
			-- sent immediately following a client heartbeat that was received (Receive)


end
