puts "start script"



class Task
	def initialize(time, &block)
		@sleep_time = time
		@block = block
	end

	def run
		sleep(@sleep_time)
		@block.call
	end
end

t = Task.new(2){puts "test"}

tasks = []
kill = false

thr = Thread.new do 
	sleep(2)
	puts "first thread"
end

thr2 = Thread.new do 
	5.times do |i|
		sleep(5)
		puts "second thread"

		tasks << Task.new(2) {puts "some new task for time #{i}"}
	end
	kill = true
	Thread.current.kill
end

thr_loop = Thread.new do
	loop do
		sleep(2)
		if tasks.length > 0
			tasks.each do |t|
				t.run
			end
		end
		puts "loop thread"
		if kill
			Thread.current.kill
		end
	end
end

puts "code after threads"


puts "end script"

thr.join
thr2.join
thr_loop.join