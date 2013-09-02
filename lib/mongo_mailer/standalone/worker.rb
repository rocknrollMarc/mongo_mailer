module MongoMailer
  class Worker
    attr_reader :configuration, :name

    def initialize
      @configuration = Configuration.instance
      @name = "mongo_mailer_worker"
    end

    def run!
      app_group = Daemons.run_proc(name, configuration.daemon_options) do
        mail_queue = MailQueue.instance

        loop do
          mail_queue.find_and_deliver!
          sleep(0.1)
        end
      end

      puts app_group.find_applications_by_app_name(name).map{|app| app.pid.pid}.join("\n")
    end
  end
end