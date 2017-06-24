require 'speedtest'
require 'mail'
require 'parseconfig'

class Netservate
  # Initialization method.
  def initialize(options = {})
    @config = ParseConfig.new('./config/netservate.conf')
    @wait_time = @config['NETSERVATE']['TEST_INTERVAL'].to_i || 900
    @failed_test_count = 0
    # Mail setup
    @mail = Mail.new()
    @mail.to = @config['EMAIL']['DESTINATION_ADDRESS']
    @mail.from = "Netservate <#{@config['EMAIL']['ORIGIN_ADDRESS']}>"
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
      # Log results
      begin
        logger = Logger.new('./log/netservate.log', 10, 1024000)
        logger.info result_text
      rescue
      end
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
    # Text part of the email - usually not seen.
    text_part = Mail::Part.new do
      body options[:message]
    end
    # HTML part of email. Include results as table.
    results_table = results_to_html
    html_part = Mail::Part.new do
      content_type 'text/html; charset=UTF-8'
      body "<table style='font-family:Helvetica,Arial,sans-serif;font-size:16px;"\
        "text-align:left;color:#333333;width:100%;'><tr><td>"\
        "<h1>Netservate Alert</h1><p>#{options[:message]}</p>#{results_table}"\
        "<p>Check your system for the full logs.</p></td></tr></table>"
    end
    # Assign mail parts to email.
    @mail.text_part = text_part
    @mail.html_part = html_part
    # Send email
    puts "Sending email to #{@config['EMAIL']['DESTINATION_ADDRESS']}..."
    if @mail.deliver
      puts "Email sent."
    else
      puts "Email was not sent successfully."
      puts "Please check your Netservate configuration file."
    end
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
