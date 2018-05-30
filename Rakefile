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

  images = `git diff --name-only --cached --diff-filter=AM | grep assets/images`.split("\n")

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

desc 'Generate the sitemap.xml'
task 'sitemap' do
  require 'rexml/document'

  def item(url, frequency, priority)
    <<~CONTENT
      <url>
        <loc>https://www.metaflop.com#{url}</loc>
        <changefreq>#{frequency}</changefreq>
        <priority>#{priority}</priority>
      </url>
    CONTENT
  end

  def config_items(config_name)
    items = YAML.load(File.read("config/#{config_name}.yml"))[config_name].map(&:first)
    items.map do |item|
      item("/#{config_name}/#{item}", 'monthly', '0.80')
    end
  end

  items = [
    item('', 'always', '1.00'),
    item('/modulator', 'always', '0.90'),

    config_items('metafonts'),
    config_items('showcases'),

    item('/about', 'monthly', '0.70'),
    item('/faq', 'monthly', '0.60')
  ].flatten

  content = <<~CONTENT
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      #{items.join}
    </urlset>
  CONTENT

  xml = REXML::Document.new(content)
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true

  File.write(
    'public/sitemap.xml',
    <<~CONTENT
      <?xml version="1.0" encoding="UTF-8"?>
      #{formatter.write(xml.root, '')}
    CONTENT
  )
end
