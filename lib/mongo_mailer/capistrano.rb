Capistrano::Configuration.instance.load do
  after "deploy", "mongo_mailer:consider_restarting"

  namespace :mongo_mailer do
    def roles
      fetch(:mongo_mailer_server_role, :app)
    end

    def command_prefix
      "cd #{current_path} && if [ -f bin/mongo_mailer ]; then SCRIPT_PATH='bin/mongo_mailer'; else SCRIPT_PATH='script/mongo_mailer'; fi && bundle exec $SCRIPT_PATH"
    end

    desc "Stop the mongo_mailer process"
    task :stop, :roles => lambda { roles } do
      run "#{command_prefix} stop #{rails_env}"
    end

    desc "Start the mongo_mailer process"
    task :start, :roles => lambda { roles } do
      run "#{command_prefix} start #{rails_env}"
    end

    desc "Restart the mongo_mailer process"
    task :restart, :roles => lambda { roles } do
      run "#{command_prefix} restart #{rails_env}"
    end

    desc "Restart the mongo_mailer process"
    task :consider_restarting, :roles => lambda { roles } do
      logger.info "Consider restarting mongo_mailer after deploy: `bundle exec cap #{fetch(:stage)} mongo_mailer:restart`"
    end
  end
end
