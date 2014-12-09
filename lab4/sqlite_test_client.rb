#file: db_controller.rb
require "sqlite3"

class DB_controller
	def initialize(db_name)
		@db_name = db_name
		@db = SQLite3::Database.open @db_name
		create_table
		ObjectSpace.define_finalizer(self, proc { @db.close if @db })
	end

	def exequte_sql(sql_string)
		begin
			stm = @db.prepare sql_string
			rs = stm.execute
		rescue SQLite3::Exception => e 
			puts "Exception occurred"
			puts e
			return false
		ensure
			return rs
		end
	end

	def create_table
		sql_string = <<-SQL
				CREATE TABLE IF NOT EXISTS Clients
				(
					id INTEGER PRIMARY KEY, 
					name TEXT,
					status INT
				);
			SQL

		exequte_sql(sql_string)

		sql_string = <<-SQL
				CREATE TABLE IF NOT EXISTS Threads
				(
					id INTEGER PRIMARY KEY,
					client_id INTEGER,
					priority INT,
					task TEXT,
					memory INT,
					duration_time INT
				);
			SQL
		exequte_sql(sql_string)
	end

	def select_status_table
		sql_string = <<-SQL
			select clients.id as "client_id",
			 clients.name as "client_name",
			  clients.status as "client_status",
			   threads.id as "thread_id",
			    threads.priority,
			     threads.task,
			      threads.memory,
			       threads.duration_time 
			from threads
			cross join clients
			on clients.id = threads.client_id;
		SQL

		result = exequte_sql(sql_string)
		puts "result #{result}"
=begin
		html_code = "<table>\n"
		html_code += "\t<row>\n\t\t"

		result.columns.each do |col_name|
			html_code += "<col>#{col_name}</col>"
		end
		html_code += "\n\t<row>\n"

		result.each do |row|
			html_code += "\t<tr>\n\t\t"
			row.each do |col|
				html_code += "<td>#{col}</td>"
			end
			html_code += "\n\t</tr>\n"
		end

		html_code += "</table>"
=end
		html_code = ""
		result.columns.each do |col_name|
			html_code += "\t#{col_name}\t|"
		end
		
		result.each do |row|
			html_code += "\n"
			row.each do |col|
				html_code += "\t#{col}\t|"
			end
		end

		return html_code
	end

	def add_client(client_hash)
		id = client_hash["id"]
		name = client_hash["name"]
		status = client_hash["status"]

		if id and name and status
			sql_string = "INSERT INTO Clients VALUES(#{id},'#{name}', '#{status}');"
			result = exequte_sql sql_string
			return result
		else
			return false
		end
	end

	def add_thread_for_client(thread_hash, client_id)
		id = thread_hash["id"]
		priority = thread_hash["priority"]
		task = thread_hash["task"]
		memory = thread_hash["memory"]
		duration_time = thread_hash["duration_time"]

		[client_id, id, priority, task, memory, duration_time].each do |e|
			if not e
				return false
			end
		end

		sql_string = "INSERT INTO Threads VALUES(#{id}, #{client_id}, #{priority},  '#{task}', #{memory}, #{duration_time});"
		result = exequte_sql sql_string
		return result
	end

	def delete_thread_with_id(thread_id)
		sql_string = "DELETE FROM threads WHERE id = #{thread_id};"
		result = exequte_sql sql_string
		puts "\n\n\nIN delete_thread_with_id #{thread_id}\n\n\n"
		if result
			puts "result #{result}"
			puts result.columns.each {|c| puts c}
		end

		return result
	end

	def delete_client_with_id(client_id)
		sql_string = "DELETE FROM threads WHERE client_id = #{client_id};"
		threads_deleted_result = exequte_sql sql_string

		sql_string = "DELETE FROM clients WHERE id = #{client_id};"
		clients_deleted_result = exequte_sql sql_string

		puts "threads_deleted_result = #{threads_deleted_result}"
		puts "clients_deleted_result = #{clients_deleted_result}"

		if threads_deleted_result and clients_deleted_result
			return true
		end

		return false
	end

	def client_hash_with_params(id,name,status)
		{"id" => id, "name" => name, "status" => status }
	end

	def thread_hash_with_params(id,priority,task,memory,duration_time)
		{"id" => id,
		 "priority" => priority,
		 "task" => task,
		 "memory" => memory,
		 "duration_time" => duration_time}
	end

	def test_insert
		exequte_sql	"DELETE FROM clients;"
		exequte_sql	"DELETE FROM threads;"
		exequte_sql	"INSERT INTO Clients VALUES(1,'Bot 1', 102);"
		exequte_sql	"INSERT INTO Clients VALUES(2,'Bot 2', 102);"

		exequte_sql	"INSERT INTO Threads VALUES(10,1,103, 'some task for user 103',1000,60);"
		exequte_sql	"INSERT INTO Threads VALUES(11,2,104, 'some task for user 104',1000,60);"
		exequte_sql	"INSERT INTO Threads VALUES(13,2,106, 'some task for user 106',1000,60);"
		exequte_sql	"INSERT INTO Threads VALUES(14,2,107, 'some task for user 107',1000,60);"
		exequte_sql	"INSERT INTO Threads VALUES(15,2,108, 'some task for user 108',1000,60);"
	end
end

dbc = DB_controller.new("test.db")
dbc.test_insert
html = dbc.select_status_table
puts "11111"
puts html

# puts "\n\n"

# result = dbc.exequte_sql "select * from threads;"
# result.each do |row|
# 	row.each do |col|
# 		print "\t#{col}\t|"
# 	end
# 	puts
# end

# puts "\n\n"

# result = dbc.exequte_sql "select * from clients;"
# result.each do |row|
# 	row.each do |col|
# 		print "\t#{col}\t|"
# 	end
# 	puts
# end


# deleted_row = dbc.delete_thread_with_id(14)
# puts "delete_thread_with_id = #{deleted_row}"


# puts "22222"
# html = dbc.select_status_table
# puts html


# deleted_row = dbc.delete_client_with_id(2)
# puts "delete_client_with_id = #{deleted_row}"

# puts "33333"
# html = dbc.select_status_table
# puts html


# client = dbc.add_client(dbc.client_hash_with_params(100,"test","ssssss"))
# if client
# 	puts "client #{client}"
# else
# 	puts "client false"
# end


# thread = dbc.add_thread_for_client(dbc.thread_hash_with_params(1333,1,"ssssss",200,60),100)
# if thread
# 	puts "thread #{thread}"
# else
# 	puts "thread false"
# end

# html = dbc.select_status_table
# puts html


