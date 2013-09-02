require 'active_support/all'
require 'mail'
require 'mongo'
require 'excon'
require 'daemons'
require 'singleton'
require 'mongo_mailer/version'
require 'mongo_mailer/configuration'

require 'mongo_mailer/common/has_mongo_collection'
Dir[File.expand_path('../mongo_mailer/common/*', __FILE__)].each do |lib|
  require lib
end