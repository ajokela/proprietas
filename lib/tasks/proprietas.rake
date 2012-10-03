require 'rake/hooks'
require 'ext/activerecord_migration_ext'

after :rails_env do
  ActiveRecord::Base.establish_connection
end 

class Rake::Task
  def overwrite(&block)
    @actions.clear
    enhance(&block)
  end  
end

@config = nil

namespace :debug do
  
  desc "Ruby Console"
  task :console do
    require 'pry'
    binding.pry
  end
  
end

Rake::Task["db:drop"].overwrite {
    
  path = File.join(Rails.root.to_s, 'app', 'models', '**/*.rb')
  
  models = ['schema_migrations', 'sessions']
  
  models.concat Dir.glob(path).map { |file|
    File.basename(file).sub(/\.rb$/, '').pluralize
  }
  
  ActiveRecord::Base.establish_connection
  
  models.each do |model|
    begin
      ActiveRecord::Base.connection.execute("DROP TABLE #{model} CASCADE")
    rescue Exception => e
      $stderr.puts e
    end
  end
  
}

Rake::Task["db:test:purge"].overwrite {
  Rake::Task["db:drop"].invoke
}

Rake::Task["db:schema:load"].overwrite {  
  Rake::Task["db:migrate"].invoke
}

before :spec do 
  Rake::Task["proprietas:db:seed"].execute
end

#Rake::Task["test"].overwrite {
  
  #Rake::Task["proprietas:db:seed"].execute
  #Rake::Task["spec"].execute
  
#}



namespace :proprietas do
  
  namespace :db do
    
    task :seed do
      Rake::Task['db:migrate'].invoke
      
      require 'proprietas/rabl'
      
      rb = Proprietas::Rabl.new(:file => File.join(Rails.root.to_s, 'data', 'yaml', 'melange.yml'),
                                :special_columns => [],
                                :delete_all => true,
                                :cache_enabled => true,
                                :search_columns => { :name => true },
                               )

      rb.scoop
      
    end
    
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

def config=(cfg)
  @config = cfg
end

def config
  @config
end

Rake::TaskManager.record_task_metadata = true

