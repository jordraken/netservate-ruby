require 'speedtest'
require 'webrick'
require 'mail'
require 'parseconfig'
require "#{__dir__}/netservate"

class Netservate

  # Initialization method.
  def initialize(options = {})
    @version = "0.1.0"
    @root_path = File.expand_path("..", __dir__)
    config_path = "#{@root_path}/config/netservate.conf"
    @config = ParseConfig.new(config_path)
    @wait_time = @config['NETSERVATE']['TEST_INTERVAL'].to_i || 900
    @fail_wait_time = @config['NETSERVATE']['TIME_AFTER_FAIL'].to_i || 60
    @failed_test_count = 0
    # Carries last 20 test results
    @results = []
  end

  # Main thread - run netspeed tests.
  def main
    puts "Running Netservate #{@version}..."
    # Main loop
    while true do
      # Run test
      puts "\nBeginning network test..."
      test_time = Time.now.strftime('%c')
      test = Speedtest::Test.new()
      net_results = test.run
      # Print results
      result_text = "\nServer: #{net_results.server}\n"\
        "Download rate: #{net_results.pretty_download_rate}\n"\
        "Upload rate: #{net_results.pretty_upload_rate}\n"\
        "Latency: #{net_results.latency}\n"\
        "Time: #{test_time}\n"
      puts result_text
      # Store results in array
      if @results.length >= 20
        @results.shift # Remove first result if 20
      end
      @results.push({
        server: net_results.server,
        download: net_results.pretty_download_rate,
        upload: net_results.pretty_upload_rate,
        time: test_time
      })
      # Log results
      begin
        logger = Logger.new("#{@root_path}/log/netservate.log", 10, 1024000)
        logger.info result_text
      rescue => error
        puts "ERROR: " + error
      end
      # Check criteria
      if (net_results.pretty_download_rate.to_f < @config['NETSERVATE']['MIN_DOWNLOAD_SPEED'].to_f) ||
        (net_results.pretty_upload_rate.to_f < @config['NETSERVATE']['MIN_UPLOAD_SPEED'].to_f)
        @failed_test_count += 1
        puts "Test does not meet criteria. (#{@failed_test_count})"
        # If too many fails in a row - send an alert.
        if (@failed_test_count % @config['NETSERVATE']['FAILS_IN_A_ROW'].to_i == 0)
          send_alert(
            subject: "Netservate Alert",
            message: "There have been #{@failed_test_count.to_s} failed network speed tests in a row."
          )
        end
        # Wait before next loop - Reset if max fail count reached.
        if @failed_test_count < @config['NETSERVATE']['MAX_FAILS_IN_A_ROW'].to_i
          puts "\nNext test in #{@fail_wait_time} seconds..."
          sleep(@fail_wait_time)
        else
          puts "\nMax fails in a row reached..."
          puts "Next test in #{@wait_time} seconds..."
          @failed_test_count = 0
          sleep(@wait_time)
        end
      else
        @failed_test_count = 0
        puts "Test meets criteria."
        puts "\nNext test in #{@wait_time} seconds..."
        # Wait before next loop
        sleep(@wait_time)
      end
    end
  end

  # For sending email alerts
  def send_alert(options = {})
    results_table = results_to_html
    html_part = "<table style='font-family:Helvetica,Arial,sans-serif;font-size:16px;"\
      "text-align:left;color:#333333;width:100%;'><tr><td>"\
      "<h1>Netservate Alert</h1><p>#{options[:message]}</p>#{results_table}"\
      "<p>Check your system for the full logs.</p></td></tr></table>"
    mailer = Mailer.new
    mailer.send(subject: "Netservate Alert", html: html_part, text: options[:message])
  end

  # Takes the stored results and formats them for HTML
  def results_to_html
    results_html = "<p>Here are the last #{@results.length} test results:</p>"\
      "<table style='width:100%;font-size:11px;'><tr>"\
      "<th align='left'>Server</th><th align='left'>Download</th>"\
      "<th align='left'>Upload</th><th align='left'>Time</th></tr>"
    @results.each do |result|
      results_html += "<tr><td>#{result[:server]}</td><td>#{result[:download]}</td>"
      results_html += "<td>#{result[:upload]}</td><td>#{result[:time]}</td></tr>"
    end
    results_html += "</table>"
    return results_html
  end

  # Listen for inputs while running tests.
  def input_listener
    print "'Ctrl-C' to quit...\n"
    while true do
      input = gets.chomp.to_s.downcase
      if ['v','version'].include?(input)
        puts "Netservate #{@version}"
      else
        puts "\nNot a valid input."
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
