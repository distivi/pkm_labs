#!/usr/bin/env ruby -w

require "socket"
require 'uri'
require "http/parser"
require 'json'


READ_CHUNK = 1024 * 4

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


class RESTfulParser
	def parse_request(request_line)
		puts "request_line #{request_line}"
		chunks = request_line.split(" ")
		method = chunks[0]
		request_uri = chunks[1]


		puts "method #{method}"
		puts "request_uri #{request_uri}"
		
		result = nil
		type = nil

		type, result = case method
		when "GET"
			parse_get(request_uri)
		when "POST"
			parse_post(request_uri)
		when "PUT"
			parse_post(request_uri)
		when "DELETE"
			parse_delete(request_uri)
		end

		puts "type: #{type}, result: #{result}"

		return type, result
	end

	def parse_get(uri)
		path = URI(uri).path
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
		return "path", File.join(WEB_ROOT, *clean)
	end

	def parse_post(uri)
		puts "parse_post #{uri}"
		return "json", {success: "post parrams"}
	end

	def parse_delete(uri)
		return "json", {"test" => "delete message"}
	end
end


class Server
	def initialize( port, ip )
		@server = TCPServer.open( ip, port )
		@requests_parser = RESTfulParser.new()
		run
	end

	def requested_file(request_line)
		# puts "request_line #{request_line}"

		request_uri  = request_line.split(" ")[1]
		# puts "[0] #{request_line.split(" ")[0]}"
		# puts "request_uri #{request_uri}"
		path = URI(request_uri).path
		# puts "URI(request_uri).path === #{path}"

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

	def send_file_to_client(path, client)
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
	end

	def send_json_to_client(json,client)
		json_string = json.to_json

		client.print "HTTP/1.1 201 Created\r\n" +
					 "Content-Type: application/json; charset=utf-8\r\n" +
					 "Content-Length: #{json_string.size}\r\n" +
					 "Connection: close\r\n"

		client.print "\r\n"
		client.print json_string
	end

	def run
		loop do
			Thread.start(@server.accept) do | client |
				request = client.gets.chop

				# puts "request: #{request}"
				# path = requested_file(request)
				type, result = @requests_parser.parse_request(request)
				if type == "path"
					puts "send file or 404"
					send_file_to_client(result,client)
				else
					puts "send JSON #{result}"
					send_json_to_client(result,client)
				end
				

				# Close the client, terminating the connection
				client.close
			end
		end
	end
end

port = ARGV[0] || 3000 
Server.new( port, "localhost" )
