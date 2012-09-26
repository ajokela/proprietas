Rake::Task["db:test:purge"].overwrite {}
Rake::Task["db:schema:load"].overwrite {}

Rake::Task["test"].overwrite do

  path = File.join(Rails.root.to_s, 'app', 'models', '**/*.rb')
  
  models = ['schema_migrations']
  
  models.concat Dir.glob(path).map { |file|
    File.basename(file).sub(/\.rb$/, '').pluralize
  }
  
  
  
end