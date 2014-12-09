#!/usr/bin/env ruby -w

require "socket"
require 'uri'
require "http/parser"
require 'json'
require 'webrick'
require 'stringio'

#local files
require './restful_parser'
require './db_controller'


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


class Server
	def initialize( port, ip )
		@server = TCPServer.open( ip, port )
		@requests_parser = RESTfulParser.new()
		run
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
		client.print "HTTP/1.1 200 OK\r\n" +
					 "Content-Type: application/json; charset=utf-8\r\n" +
					 "Content-Length: #{json_string.size}\r\n" +
					 "Connection: close\r\n"

		client.print "\r\n"
		client.print json_string
	end

	def send_html_to_client(html,client)
		client.print "HTTP/1.1 200 OK\r\n" +
					 "Content-Type: application/html; charset=utf-8\r\n" +
					 "Content-Length: #{html.size}\r\n" +
					 "Connection: close\r\n"

		client.print "\r\n"
		client.print html
	end

	def run
		loop do
			Thread.start(@server.accept) do | client |
				# request = client.gets.chop
				puts "cluent accepted"
				data = ""
				while (tmp = client.read(1024))
				    data += tmp
				end
				puts "data\n#{data}"

				
				req = WEBrick::HTTPRequest.new(WEBrick::Config::HTTP)
				req.parse(StringIO.new(data))

				puts req.path
				req.each { |head| puts "#{head}:  #{req[head]}" }
				puts req.body
				

				# path = requested_file(request)
				type, result = @requests_parser.parse_request(req.path, req.body)

				case type
				when "path"
					send_file_to_client(result,client)
				when "html"
					send_html_to_client(result,client)
				when "json"
					send_json_to_client(result,client)
				else 
					send_html_to_client("Bad request",client)
				end

				# Close the client, terminating the connection
				client.close
			end
		end
	end
end

# dbc = DB_controller.new("test.db")
# dbc.test_insert
# html = dbc.select_status_table
# puts "11111"
# puts html

port = ARGV[0] || 3000 
Server.new( port, "localhost" )

