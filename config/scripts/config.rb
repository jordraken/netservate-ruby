require 'parseconfig'

def get_input
  input = gets.chomp.to_s.downcase
  return input
end

config = ParseConfig.new('./config/netservate.conf')

# Begin config process
puts "Beginning Netservate configuration process..."



# Email config
loop do
  print "\nWould you like to set up your email settings? (Y/N): "
  input = get_input
  if ['y', 'yes'].include?(input)
    puts "\nBeginning email setup..."
    puts "Leaving inputs empty will keep current settings."
    # Server
    puts "\nEnter your server name. Ex: in-v3.mailjet.com"
    puts "Netservate uses SMTP to send email."
    print "SERVER NAME: "
    input = get_input
    config["EMAIL"]["SERVER"] = input if input != ""
    # Port
    puts "\nEnter your server port. Ex: 587"
    print "PORT: "
    input = get_input
    config["EMAIL"]["PORT"] = input if input != ""
    # Username
    puts "\nEnter your username for the server."
    print "USERNAME: "
    input = get_input
    config["EMAIL"]["USERNAME"] = input if input != ""
    # Password
    puts "\nEnter your password for the server."
    print "PASSWORD: "
    input = get_input
    config["EMAIL"]["PASSWORD"] = input if input != ""
    # Who is sending
    puts "\nSet up who sends and receives email alerts. Origin and destination."
    puts "If you are sending mail to yourself, you can use the same address."
    # Origin address
    print "ORIGIN ADDRESS: "
    input = get_input
    config["EMAIL"]["ORIGIN_ADDRESS"] = input if input != ""
    # Destination address
    print "DESTINATION ADDRESS: "
    input = get_input
    config["EMAIL"]["DESTINATION_ADDRESS"] = input if input != ""
    # Display settings
    puts "\nHere are your new email settings:"
    puts "SERVER: #{config["EMAIL"]["SERVER"]}"
    puts "PORT: #{config["EMAIL"]["PORT"]}"
    puts "USERNAME: #{config["EMAIL"]["USERNAME"]}"
    puts "PASSWORD: #{config["EMAIL"]["PASSWORD"]}"
    puts "ORIGIN: #{config["EMAIL"]["ORIGIN_ADDRESS"]}"
    puts "DESTINATION: #{config["EMAIL"]["DESTINATION_ADDRESS"]}"
    # End email setup
    puts "\nEmail setup complete."
    break
  elsif ['n', 'no'].include?(input)
    puts "Skipping email settings..."
    break
  end
end

# Netservate config
loop do
  print "\nWould you like to set up your Netservate settings? (Y/N): "
  input = get_input
  if ['y', 'yes'].include?(input)
    puts "\nBeginning Netservate setup..."
    puts "Leaving inputs empty will keep current settings."
    # Min download
    puts "\nWhat is your minimum acceptable download rate (in Mbps)?"
    puts "Current: #{config["NETSERVATE"]["MIN_DOWNLOAD_SPEED"]}"
    print "MIN DOWNLOAD: "
    input = get_input
    config["NETSERVATE"]["MIN_DOWNLOAD_SPEED"] = input if input != ""
    # Min download
    puts "\nWhat is your minimum acceptable upload rate (in Mbps)?"
    puts "Current: #{config["NETSERVATE"]["MIN_UPLOAD_SPEED"]}"
    print "MIN UPLOAD: "
    input = get_input
    config["NETSERVATE"]["MIN_UPLOAD_SPEED"] = input if input != ""
    # Test interval
    puts "\nHow often should Netservate typically run network tests (in seconds)?"
    puts "Current: #{config["NETSERVATE"]["TEST_INTERVAL"]}"
    print "TEST INTERVAL: "
    input = get_input
    config["NETSERVATE"]["TEST_INTERVAL"] = input if input != ""
    # Failed Test interval
    puts "\nIf a test fails, how long should the wait be before the next one (in seconds)?"
    puts "Current: #{config["NETSERVATE"]["TIME_AFTER_FAIL"]}"
    print "TIME AFTER FAIL: "
    input = get_input
    config["NETSERVATE"]["TIME_AFTER_FAIL"] = input if input != ""
    # Fails in a row
    puts "\nHow many tests should fail in a row before an email is sent?"
    puts "Current: #{config["NETSERVATE"]["FAILS_IN_A_ROW"]}"
    print "FAILS IN A ROW: "
    input = get_input
    config["NETSERVATE"]["FAILS_IN_A_ROW"] = input if input != ""
    # Max fails
    puts "\nIf tests continue to fail..."
    puts "What is the maximum number of failures you want to be notified about?"
    puts "(Emails will stop being sent if this number is surpassed.)"
    puts "Current: #{config["NETSERVATE"]["MAX_FAILS_IN_A_ROW"]}"
    print "MAX FAILS IN A ROW: "
    input = get_input
    config["NETSERVATE"]["MAX_FAILS_IN_A_ROW"] = input if input != ""
    # Display settings
    puts "\nHere are your new Netservate settings:"
    puts "MIN DOWNLOAD: #{config["NETSERVATE"]["MIN_DOWNLOAD_SPEED"]}"
    puts "MIN UPLOAD: #{config["NETSERVATE"]["MIN_UPLOAD_SPEED"]}"
    puts "TEST INTERVAL: #{config["NETSERVATE"]["TEST_INTERVAL"]}"
    puts "TIME AFTER FAIL: #{config["NETSERVATE"]["TIME_AFTER_FAIL"]}"
    puts "FAILS IN A ROW: #{config["NETSERVATE"]["FAILS_IN_A_ROW"]}"
    puts "MAX FAILS IN A ROW: #{config["NETSERVATE"]["MAX_FAILS_IN_A_ROW"]}"
    # End Netservate setup
    puts "\nNetservate setup complete."
    break
  elsif ['n', 'no'].include?(input)
    puts "Skipping Netservate settings..."
    break
  end
end

puts "\nApplying new settings to config file..."

# Write changes to file
file = File.open('./config/netservate.conf', 'w')
config.write(file)
file.close

puts "Netservate configuration complete."
