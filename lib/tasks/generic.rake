Rake::Task["db:drop"].overwrite {
  
  path = File.join(Rails.root.to_s, 'app', 'models', '**/*.rb')
  
  models = ['schema_migrations']
  
  models.concat Dir.glob(path).map { |file|
    File.basename(file).sub(/\.rb$/, '').pluralize
  }
  
  ActiveRecord::Base.establish_connection
  
  models.each do |model|
    ActiveRecord::Base.connection.execute("DROP TABLE #{model}")
  end
  
}

Rake::Task['db:migrate'].overwrite {
  Rake::Task['proprietas:db:_db_env:load_config'].invoke
  
  ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
  ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths, ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  
}

namespace :proprietas do
  namespace :db do
    namespace :_db_env do
      
      desc "Load database.yml and get the database configs"
      task :load_config => [:rails_env] do
        
        environ = Rails.env
        
        unless ENV["RAILS_ENV"].nil?
          environ = ENV["RAILS_ENV"]
        end
          
        @config = Rails.configuration.database_configuration[environ]
        
        require File.expand_path(File.join(File.dirname(__FILE__), '../ext/activerecord_ext'))
      end
            
    end
  end
end