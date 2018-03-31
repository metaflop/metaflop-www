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

desc 'Optimize images in the git staging area'
task 'optimize_images' do
  new_images_sub_command = "$(git diff --name-only --cached | grep assets/images)"

  `mogrify -quality 80 #{new_images_sub_command}`
  `image_optim #{new_images_sub_command}`
end

desc 'ESLint'
task 'eslint' do
  system 'node_modules/eslint/bin/eslint.js assets/javascripts/*.js'
end
