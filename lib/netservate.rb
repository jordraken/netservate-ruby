require 'speedtest'
require 'mail'
require 'parseconfig'

class Netservate
  def initialize(options = {})
    @config = ParseConfig.new('./config/netservate.conf')
    @wait_time = @config['NETSERVATE']['TEST_INTERVAL'].to_i || 900
    @failed_test_count = 0

    @mail = Mail.new
    @mail.to = @config['EMAIL']['DESTINATION_ADDRESS']
    @mail.from = "Netservate " + @config['EMAIL']['ORIGIN_ADDRESS']
    @mail.subject = 'Netservate Update'

    # Carries last 20 test results
    @results = []
  end

  # Main thread - run netspeed tests.
  def main
    puts "Running Netservate..."
    # Main loop
    while true do
      # Run test
      test_time = Time.now.strftime('%c')
      test = Speedtest::Test.new()
      net_results = test.run
      # Print results
      puts "-" * 20
      puts test_time
      puts "Server: " + net_results.server
      puts "Download rate: " + net_results.pretty_download_rate
      puts "Upload rate: " + net_results.pretty_upload_rate
      # Log results
      if @results.length >= 20
        @results.shift # Remove first result if 20
      end
      @results.push({
        server: net_results.server,
        download: net_results.pretty_download_rate,
        upload: net_results.pretty_upload_rate,
        time: test_time
      })
      # Check criteria
      if (net_results.pretty_download_rate.to_f < @config['NETSERVATE']['MIN_DOWNLOAD_SPEED'].to_f) ||
        (net_results.pretty_upload_rate.to_f < @config['NETSERVATE']['MIN_UPLOAD_SPEED'].to_f)
        @failed_test_count += 1
        puts "Test does not meet criteria. (#{@failed_test_count})"
      else
        @failed_test_count = 0
        puts "Test meets criteria."
      end
      # If too many fails in a row - send an alert.
      if @failed_test_count == @config['NETSERVATE']['FAILS_IN_A_ROW'].to_i
        send_alert(
          subject: "Netservate Alert",
          message: "There have been #{@failed_test_count.to_s} failed network speed tests in a row."
        )
      end
      # Wait before next loop
      sleep(@wait_time)
    end
  end

  # For sending email alerts
  def send_alert(options = {})
    # Set up email
    @mail.subject = options[:subject]
    @mail.body = options[:message]
    # Send email
    puts "Sending email to #{@config['EMAIL']['DESTINATION_ADDRESS']}..."
    if @mail.deliver
      puts "Email sent."
    else
      puts "Email was not sent successfully."
      puts "Please check your Netservate configuration file."
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
