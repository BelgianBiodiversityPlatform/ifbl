# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Ifblserver::Application.initialize!

# Overriden in production.rb
Rails.configuration.destination_emails = {
  :technical => ['n.noe@biodiversity.be'],
  :scientific => ['niconoe@gmail.com', 'nicolas@niconoe.org']
}

