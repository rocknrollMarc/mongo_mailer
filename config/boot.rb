require 'rubygems'

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
ENV['RAILS_ENV'] ||= 'development'

require 'bundler/setup'
Bundler.require

require 'mongo_mailer/standalone'

MongoMailer::Configuration.instance.root = File.expand_path("../..", __FILE__)
MongoMailer::Configuration.instance.load!
