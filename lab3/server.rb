#!/usr/bin/env ruby -w

require "socket"
require 'uri'

WEB_ROOT = './public'

# Map extensions to their content type
CONTENT_TYPE_MAPPING = {
	'html' => 'text/html',
	'txt' => 'text/plain',
	'png' => 'image/png',
	'jpg' => 'image/jpeg',
	'js' => 'application/javascript',
	'css' => 'text/css'
}

# Treat as binary data if content type cannot be found
DEFAULT_CONTENT_TYPE = 'application/octet-stream'


class Server
	def initialize( port, ip )
		@server = TCPServer.open( ip, port )
		run
	end

	def requested_file(request_line)
		request_uri  = request_line.split(" ")[1]
		path = URI(request_uri).path

		clean = []

		# Split the path into components
		parts = path.split("/")

		parts.each do |part|
			# skip any empty or current directory (".") path components
			next if part.empty? || part == '.'
			# If the path component goes up one directory level (".."),
			# remove the last clean component.
			# Otherwise, add the component to the Array of clean components
			part == '..' ? clean.pop : clean << part
		end

		# return the web root joined to the clean path
		File.join(WEB_ROOT, *clean)
	end

	def content_type(path)
		ext = File.extname(path).split(".").last
		CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
	end

	def run
		loop do
			Thread.start(@server.accept) do | client |
				request = client.gets.chop
				
				puts "request: #{request}"
				path = requested_file(request)
				path = File.join(path, 'index.html') if File.directory?(path)

				if File.exist?(path) && !File.directory?(path)
					File.open(path, "rb") do |file|
						client.print "HTTP/1.1 200 OK\r\n" +
									 "Content-Type: #{content_type(file)}\r\n" +
									 "Content-Length: #{file.size}\r\n" +
									 "Connection: close\r\n"

						client.print "\r\n"

						# write the contents of the file to the client
						IO.copy_stream(file, client)
					end
				else
					message = "File not found\n"

					# respond with a 404 error code to indicate the file does not exist
					client.print "HTTP/1.1 404 Not Found\r\n" +
								 "Content-Type: text/plain\r\n" +
								 "Content-Length: #{message.size}\r\n" +
								 "Connection: close\r\n"

					client.print "\r\n"

					client.print message
				end

				# Close the client, terminating the connection
				client.close
			end
		end
	end
end

port = ARGV[0] || 3000 
Server.new( port, "localhost" )
