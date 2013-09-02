require 'rails/generators'

class MongoMailerGenerator < Rails::Generators::Base

  self.source_paths << File.join(File.dirname(__FILE__), 'templates')

  def create_script_file
    target_dir  = (ActiveSupport::VERSION::MAJOR >= 4) ? 'bin' : 'script'
    target_path = File.join(target_dir, 'mongo_mailer')
    template 'script', target_path
    chmod target_path, 0755
  end

  def create_config_files
    template 'mongo_mailer.yml', 'config/mongo_mailer.yml.example'
  end
end
