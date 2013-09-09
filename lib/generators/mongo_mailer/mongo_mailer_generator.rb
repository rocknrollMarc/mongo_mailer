require 'rails/generators'

class MongoMailerGenerator < Rails::Generators::Base

  self.source_paths << File.join(File.dirname(__FILE__), 'templates')

  def create_config_files
    template 'mongo_mailer.yml', 'config/mongo_mailer.yml.example'
  end
end
