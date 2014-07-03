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

  # we need to manually convert the params property to yaml
  # in order for the finder to work
  class << self
    alias_method :super_first_or_create, :first_or_create

    def first_or_create(properties)
      if properties[:params]
        properties[:params] = YAML.dump(properties[:params])
      end

      super_first_or_create(properties)
    end
  end
end
