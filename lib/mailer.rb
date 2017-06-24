require 'mail'
require 'parseconfig'

class Mailer

  def initialize
    @config = ParseConfig.new('./config/netservate.conf')
    @queued_emails = []
    # Mail setup
    @mail = Mail.new()
    @mail.to = @config['EMAIL']['DESTINATION_ADDRESS']
    @mail.from = "Netservate <#{@config['EMAIL']['ORIGIN_ADDRESS']}>"
    @mail.subject = 'Netservate Update'
  end

  def send(options = {})
    thread = Thread.new do
      send_attempts = 0
      while true do
        @mail.subject = options[:subject] || @mail.subject
        if ![nil, ""].include?(options[:text])
          text_part = Mail::Part.new do
            body options[:text]
          end
          @mail.text_part = text_part
        end
        if ![nil, ""].include?(options[:html])
          html_part = Mail::Part.new do
            content_type 'text/html; charset=UTF-8'
            body options[:html].to_s
          end
          @mail.html_part = html_part
        end
        puts "Sending email to #{@config['EMAIL']['DESTINATION_ADDRESS']}..."
        begin
          @mail.deliver
          puts "Email sent."
          break
        rescue => error
          puts "Email was not sent successfully."
          puts error
        end
        # If it gets here - something has gone wrong. Give up after 5 attempts.
        send_attempts += 1
        if send_attempts >= 5
          thread.exit
        end
      end
    end
  end

end
