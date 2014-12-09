#file: restful_parser.rb

#local files
require './db_controller'

class RESTfulParser
	def initialize
		@DBController = DB_controller.new("development.db")
	end

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
		puts "===>>>PATH #{path}"
		case path
		when "/info"
			return get_task_manager_table
		end

		return get_file_for_path(path)
	end

	def get_file_for_path(path)
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

	def get_task_manager_table
		html = @DBController.select_status_table
		return "html", html
	end

	def parse_post(uri)
		puts "parse_post #{uri}"
		return "json", {success: "post parrams"}
	end

	def parse_delete(uri)
		return "json", {"test" => "delete message"}
	end
end