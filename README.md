# Eiffel_Discord_POC

A proof of concept for the Eiffel Discord library.

To use it, you will have to create a Bot dans put the secret key of the bot in a bot_token file.

To use in on Linux Ubuntu, you need to:
	- compile openssl by hand. 
	- Removing everything related to SSLv3 in $ISE_LIBRARY/unstable/library/network/socket/netssl/ssl/ssl_context.e 
