require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter '/spec/'
end

require 'rubygems'

ENV["RAILS_ENV"] = ENV["APP_ENV"] = 'test'

require File.expand_path("../../config/boot", __FILE__)
require 'rspec/autorun'

RSpec.configure do |config|
  config.order = "random"
  config.color_enabled = true

  config.before(:suite) do
    drop_db
  end
end

def drop_db
  MongoMailer::Configuration.instance.mongodb.command(:dropDatabase => 1)
end