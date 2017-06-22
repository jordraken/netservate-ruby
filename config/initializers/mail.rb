require 'mail'
require 'parseconfig'

config = ParseConfig.new('./config/mail.conf')

options = { :address              => "smtp.gmail.com",
            :port                 => 587,
            :domain               => 'gmail.com',
            :user_name            => config['username'],
            :password             => config['password'],
            :authentication       => 'plain',
            :enable_starttls_auto => true  }

Mail.defaults do
  delivery_method :smtp, options
end
