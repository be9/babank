environment ENV['RAILS_ENV']
threads *(ENV['PUMA_THREADS'] || '0,5').split(',')
workers ENV['PUMA_WORKERS'] || 1

preload_app!

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished

    config = Rails.application.config.database_configuration[Rails.env]
    ActiveRecord::Base.establish_connection(config)
  end
end

