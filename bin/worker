#!/usr/bin/env ruby
ENV["RAILS_ENV"] = ARGV[1] || 'development'

require File.expand_path('../../config/boot', __FILE__)

MongoMailer::Worker.new.run!