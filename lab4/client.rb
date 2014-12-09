#!/usr/bin/env ruby -w
require "socket"

class Client
	def initialize()
		puts "init"
		port = ARGV[0] || 3000
		@server = TCPSocket.open("localhost", port)
		bruteforce_run
	end


	def bruteforce_run
		puts "brut"
		thread = Thread.new do
			puts "we are in thread"
			loop { 
				puts "send request to server"
				@server.puts("PUTS") # send request
				answer = @server.gets.chomp # get response
				puts "#{answer}"
			}.join
			puts "we exit from thread"
		end
		puts "exit brut"
		thread.join
		return
	end
end

5.times do |i|
	Thread.new do
		puts "create account #{i}"
		Client.new()
	end.join
end

