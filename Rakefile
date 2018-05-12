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
  def file_message(message, files)
    puts message
    puts files.map { |name| "  > #{name}" }.join("\n")
  end

  images = `git diff --name-only --cached | grep assets/images`.split("\n")

  abort 'No images found. You need to stage the files first.' if images.empty?

  jpg_images = images.grep(/\.jpg$/)

  if jpg_images.any?
    file_message 'Mogrifying jpg images to 80% quality...', jpg_images
    `mogrify -quality 80 #{images.join(' ')}`
  end

  file_message 'Applying image_optim on all images...', images
  `image_optim #{images.join(' ')}`

  puts 'Done.'
end

desc 'ESLint'
task 'eslint' do
  system 'node_modules/eslint/bin/eslint.js assets/javascripts/*.js'
end
