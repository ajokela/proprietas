class Rake::Task
  def overwrite(&block)
    @actions.clear
    enhance(&block)
  end  
end

namespace :debug do
  
  desc "Ruby Console"
  task :console do
    require 'pry'
    binding.pry
  end
  
end
