require 'mongo_mailer'
require 'mongo_mailer/delivery_methods/mongo_queue'
require 'action_mailer'

ActionMailer::Base.add_delivery_method :mongo_queue, MongoMailer::DeliveryMethods::MongoQueue