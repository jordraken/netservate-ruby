require 'speedtest'
require 'mail'

class Netservate
  def initialize(options = {})
    @wait_time = options[:wait_time] || 20
  end

  # Main thread - run netspeed tests.
  def main
    print "Running Netservate...\n"
    while true do
      test = Speedtest::Test.new()
      results = test.run
      puts "-" * 20
      puts "Server: " + results.server
      puts "Download rate: " + results.pretty_download_rate
      puts "Upload rate: " + results.pretty_upload_rate
      sleep(@wait_time)
    end
  end

  # Listen for inputs while running tests.
  def input_listener
    print "Enter 'Q' to quit...\n"
    while true do
      input = gets.chomp.to_s
      if ['q', 'quit'].include?(input.downcase)
        print "Quitting...\n"
        exit
      end
    end
  end

  # Create and join threads. Run program.
  def run
    input_listener_thread = Thread.new{input_listener();}
    main_thread = Thread.new{main();}
    input_listener_thread.join
    main_thread.join
  end

end
