require './app'

# asset pipeline
require 'sinatra/asset_pipeline/task'

Sinatra::AssetPipeline::Task.define! App

# sequel migrations
desc 'Run migrations'
task 'db:migrate', [:version] do |t, args|
  Sequel.extension :migration
  if args[:version]
    puts 'Migrating to version #{args[:version]}'
    Sequel::Migrator.run(App.database, 'db/migrations', target: args[:version].to_i)
  else
    puts 'Migrating to latest'
    Sequel::Migrator.run(App.database, 'db/migrations')
  end
end
