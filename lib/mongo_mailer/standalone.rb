require 'mongo_mailer'
require 'mongo_mailer/delivery_methods/test1'
require 'mongo_mailer/delivery_methods/test2'

Dir[File.expand_path('../standalone/*', __FILE__)].each do |lib|
  require lib
end
