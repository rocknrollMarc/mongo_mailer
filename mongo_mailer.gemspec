# encoding: utf-8
require File.expand_path('../lib/mongo_mailer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Krzysztof Knapik', 'Infakt Dev Team']
  gem.email         = ['knapo@knapo.net', 'devteam@infakt.pl']
  gem.description   = %q{Rails plugin for sending asynchronous email with mongodb}
  gem.summary       = %q{Rails plugin for sending asynchronous email with mongodb}
  gem.homepage      = 'https://github.com/infakt/mongo_mailer'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.name          = 'mongo_mailer'
  gem.require_paths = ['lib']

  gem.add_dependency 'activesupport', '>= 3.2.13'
  gem.add_dependency 'mail',          '~> 2.5.4'
  gem.add_dependency 'mongo',         '~> 1.8.5'
  gem.add_dependency 'bson_ext',      '~> 1.8.5'
  gem.add_dependency 'excon',         '~> 0.20.1'
  gem.add_dependency 'daemons',       '~> 1.1.9'

  gem.add_development_dependency 'rake',      '>= 10.0.4'
  gem.add_development_dependency 'rspec',     '~> 2.14.0'
  gem.add_development_dependency 'coveralls'
  gem.add_development_dependency 'actionmailer', '>= 3.2.13'
  
  gem.version       = MongoMailer::VERSION
end

