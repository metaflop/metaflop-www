require './app'
require './views/modulator'

modulator = App::Views::Modulator.new
font_settings = FontSettings.new({})
modulator.instance_variable_set('@font_parameters', FontParameters.new({}, font_settings))

puts "updating all records..."
Url.all.each do |url|
  url.params = Hash[url.params.map { |k, v| [k.gsub('-', '_'), v] }]
  url.save
  print '.'
end

puts "\ndone."
