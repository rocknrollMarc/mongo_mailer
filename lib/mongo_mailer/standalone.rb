require 'mongo_mailer'
require 'mongo_mailer/delivery_methods/http_api'
require 'mongo_mailer/delivery_methods/test'

Dir[File.expand_path('../standalone/*', __FILE__)].each do |lib|
  require lib
end
