# MongoMailer

[![Gem Version](https://badge.fury.io/rb/mongo_mailer.png)][gem_version]
[![Build status](https://secure.travis-ci.org/infakt/mongo_mailer.png)][travis]
[![Code Climate](https://codeclimate.com/github/infakt/mongo_mailer.png)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/infakt/mongo_mailer/badge.png?branch=master)][coveralls]

[gem_version]: https://rubygems.org/gems/mongo_mailer
[travis]: http://travis-ci.org/infakt/mongo_mailer
[codeclimate]: https://codeclimate.com/github/infakt/mongo_mailer
[coveralls]: https://coveralls.io/r/infakt/mongo_mailer


## Asynchronous mail delivery with mongodb for Rails

### Elements

* Rails plugin containing delivery_method, generators, capistrano recipies
* worker daemon fetching mails for queue and doing the final delivery using two methods: base and emergency, if base delivery fails, then emergency is being used.

### Rails plugin

Add mongo_mailer to your `Gemfile`:
<pre>
gem 'mongo_mailer', require: 'mongo_mailer/rails'
</pre>

Run the generator:
<pre>
bundle exec rails generate mongo_mailer
</pre>
which creates `config/mongo_mailer.yml.example`

Based on example configuration file, create `mongo_mailer.yml` and add it to gitignored. 
`mongo_mailer.yml` contains configuration of mongo database and final delivery methods used by worker.

Set `ActionMailer::Base` delivery method in your environment file:
<pre>
config.action_mailer.delivery_method :mongo_queue
</pre>

Add mongo_mailer capistrano recipies, by adding:
<pre>
require 'mongo_mailer/capistrano'
</pre>
to your `deploy.rb`. Since then you have access to `cap mongo_mailer:start|stop|restart` recipies.

### Standalone worker

Worker can be used within a rails app or as a standalone application. In both cases only mongo_mailer related stuff is used - rails are never being loaded.

Worker usees [daemons](https://rubygems.org/gems/daemons) to daemonize the process, continuously polls mongo queue for new mail and does the final delivery.

* to start, stop or restart worker just run:
<pre>
bundle exec mongo_mailer start|stop|restart <rails_env>
</pre>
within a rails app, or:
<pre>
bundle exec worker start|stop|restart <app_env>
</pre>
in a standalone version.

* by default workers activity and pids are being loged in the app's `log` directory:
<pre>
log/mongo_mailer.output
log/mongo_mailer.log
log/mongo_mailer.pid
</pre>
you can change it, by modifying proper daemon options in `mongo_mailer.yml`.

* all sent mail are logged into:
<pre>
log/mongo_queue.log
</pre>

### Debugging & stats

mongo_mailer doesn't have any web interface, so irb console is the only interface to get information :)

#### Getting number of sent messages for each delivery method:

<pre>
MongoMailer::DeliveriesCounter.instance.by_type(:base)
=> {"_id"=>BSON::ObjectId('5177ecb0df30cc350e3fbdf3'), "type"=>:base, "value"=>11}

MongoMailer::DeliveriesCounter.instance.by_type(:emergency)
=> {"_id"=>BSON::ObjectId('5178f501df30cc350e3fbdf4'), "type"=>:base, "value"=>1}

MongoMailer::DeliveriesCounter.instance.all
=> [{"_id"=>BSON::ObjectId('5177ecb0df30cc350e3fbdf3'), "type"=>:base, "value"=>11}, {"_id"=>BSON::ObjectId('5178f501df30cc350e3fbdf4'), "type"=>:emergency, "value"=>1}]
</pre>

#### Getting list of unsent message due to errors:

<pre>
MongoMailer::MailQueue.instance.invalid_items
</pre>

#### Clearing the list of unsent messages:

<pre>
MongoMailer::MailQueue.instance.clear_invalid_items!
</pre>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
