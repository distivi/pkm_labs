#!/usr/bin/env ruby -w
require "socket"

class Client
	def initialize(args)
		@server = args["server"]
		@from = args["from"]
		@to = args["to"]

		if check_server_readiness
			bruteforce_run
		else
			close_connection
		end
	end

	def check_server_readiness
		puts "Checking server readiness"
		response = @server.gets.chomp # get response
		puts "#{response}"
		return response ? true : false
	end

	def bruteforce_run
		(@from..@to).to_a.each do |secret|
			@server.puts(secret) # send request
			answer = @server.gets.chomp # get response
			puts "#{answer}"

			tring_key, is_success = answer.gsub(/\s+/,"").split(":")

			if is_success == "success"
				close_connection
				return
			end
		end

		close_connection
	end

	def close_connection
		puts "disconnect from server"
		@server.close
	end
	
end

port = ARGV[0] || 3000

server = TCPSocket.open("localhost", port)
from = ARGV[1] || "0"
to=ARGV[2] || "9"

Client.new({"server" => server, "from" => from, "to" => to})