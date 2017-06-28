require 'mail'
require 'parseconfig'

@root_path = File.expand_path("../..", __dir__)
config = ParseConfig.new("#{@root_path}/config/netservate.conf")

options = { :address              => config['EMAIL']['SERVER'],
            :port                 => config['EMAIL']['PORT'],
            :domain               => 'localhost',
            :user_name            => config['EMAIL']['USERNAME'],
            :password             => config['EMAIL']['PASSWORD'],
            :authentication       => 'plain',
            :enable_starttls_auto => true  }

Mail.defaults do
  delivery_method :smtp, options
end
