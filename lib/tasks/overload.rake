
Rake::Task["db:test:purge"].overwrite {
  ENV["RAILS_ENV"] = "test"
  Rake::Task["db:drop"].invoke
}

Rake::Task["db:schema:load"].overwrite {
  
  Rake::Task["db:migrate"].invoke
}

Rake::Task["test"].overwrite {
  ENV["RAILS_ENV"] = "test"
  
  Rake::Task["spec"].invoke
  
}

