#!/usr/bin/env ruby -w
# help here : http://www.sitepoint.com/ruby-tcp-chat/
require "socket"

class Server
	def initialize( port, ip )
		@server = TCPServer.open( ip, port )
		@secret_key = "0666"
		run
	end

	def run
		loop {
			Thread.start(@server.accept) do | client |
				puts "Client connected #{client}"
				client.puts "Try huck me, ***** !?"
				listen_user_messages( client )
			end
		}.join
	end

	def listen_user_messages( client )
		loop {
			try_key = client.gets.chomp
			puts "client #{client} try key #{try_key}"
			equeal_keys = @secret_key == try_key
			answer = equeal_keys ? "success" : "failed"
			client.puts "#{try_key} : #{answer}"

			if equeal_keys
				disconnect_client client
				return
			end
		}
	end

	def disconnect_client(client)
		puts "disconnect client #{client}"
		client.close
	end
end

port = ARGV[0] || 3000
 
Server.new( port, "localhost" )