#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

# url shortener model
class Url
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime

  property :short, String, :length => 10, :default => lambda { |r, p| SecureRandom.urlsafe_base64[0, 10] }
  property :params, Yaml

  def params=(params)
    params = YAML.dump(params)
    super
  end

  def params
    params = YAML.load(super)
  end
end
