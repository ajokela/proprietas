require 'rake/hooks'
require 'ext/activerecord_migration_ext'

after :rails_env do
  ActiveRecord::Base.establish_connection
  require 'ext/activerecord_ext'
end 

namespace :debug do
  
  desc "Ruby Console"
  task :console do
    require 'pry'
    binding.pry
  end
  
end

