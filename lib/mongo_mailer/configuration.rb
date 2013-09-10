require 'singleton'
require 'mongo_mailer/core_ext/hash'

module MongoMailer
  class Configuration
    include Singleton

    class MissingConfigurationFile < StandardError; end
    class MissingConfigurationData < StandardError; end
    class MissingConfigurationVariables < StandardError; end

    REQUIRED_KEYS = [:mongodb, :base_delivery_method, :emergency_delivery_method]
      
    def env
      @env ||= defined?(Rails) ? Rails.env.to_s : ENV['RAILS_ENV']
    end

    def root
      return @root if @root
      @root = Rails.root if defined?(Rails)
    end

    def root=(path)
      @root = Pathname.new(path)
    end

    def configuration
      @configuration ||= load!
    end

    def load!
      unless root
        warn "`MongoMailer::Configuration.instance.root` does not seem to be set!"
        return false
      end
      
      @configuration = begin
        load_yml('config/mongo_mailer.yml')
      rescue MissingConfigurationFile
        warn "`config/mongo_mailer.yml` seems to be missing, loading `config/mongo_mailer.yml.example` file instead."
        load_yml('config/mongo_mailer.yml.example')
      end
    end

    def verify!
      missing_keys = REQUIRED_KEYS - configuration.keys
      unless missing_keys.empty?
        raise MissingConfigurationVariables("Following variables are missing in your configuration file: #{missing_keys.join(',')}")
      end
      return true
    end

    def mongodb
      configuration[:mongodb][:name] ||= 'mongo_mailer'
      @mongodb ||= ::Mongo::MongoClient.new(configuration[:mongodb][:host], configuration[:mongodb][:port]).db("#{configuration[:mongodb][:name]}_#{env}")
    end

    def lookup_delivery_method(method)
      method = ::Mail::Configuration.instance.lookup_delivery_method(method.to_s)
      return method unless method.is_a?(String)

      case method.to_sym
      when :http_api then MongoMailer::DeliveryMethods::HttpAPI
      when :test1 then MongoMailer::DeliveryMethods::Test1Mailer
      when :test2 then MongoMailer::DeliveryMethods::Test2Mailer
      else
        raise "Unknown delivery method: #{method}"
      end
    end

    def base_delivery
      @base_delivery ||= [
        lookup_delivery_method(configuration[:base_delivery_method]),
        configuration[:base_delivery_settings]
      ]
    end

    def emergency_delivery
      @emergency_delivery ||= [
        lookup_delivery_method(configuration[:emergency_delivery_method]),
        configuration[:emergency_delivery_settings]
      ]
    end

    def full_daemon_options
      opts = configuration[:daemon_options]
      opts[:log_dir] = root.join(opts[:log_dir]).to_s if opts[:log_dir]
      opts[:dir]     = root.join(opts[:dir]).to_s if opts[:dir]
      return opts
    end

    def logger
      @logger ||= init_logger
    end

    def log_error(e)
      msg = [e.inspect, e.backtrace].flatten.join("\n")
      logger.error("[ERROR] #{msg}")
    end

    private

    def init_logger
      logger = Logger.new(File.join(self.root, 'log/mongo_queue.log'), 'weekly')
      logger.formatter = Logger::Formatter.new

      log_level     = (configuration[:log_level] || :info)
      logger.level  = Logger.const_get(log_level.to_s.upcase)
      logger
    end

    def load_yml(file)
      path = File.join(self.root, file)

      unless File.exists?(path)
        raise MissingConfigurationFile.new("File #{path} was found")
      end

      yml = ::YAML.load_file(path)
      
      if yml[self.env].is_a?(Hash)
        return yml[self.env].deep_symbolize_keys
      else
        raise MissingConfigurationData.new("Configuration data for #{self.env} was not found in #{path}")
      end
    end
  end
end