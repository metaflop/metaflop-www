#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

# url shortener model
class Url < Sequel::Model
  plugin :serialization, :yaml, :params

  def before_create
    self.short = SecureRandom.urlsafe_base64[0, 10]
  end

  # we need to manually convert the params property to yaml
  # in order for the finder to work
  class << self
    def find_or_create(properties)
      if properties[:params]
        properties[:params] = YAML.dump(properties[:params])
      end

      super(properties)
    end
  end
end
