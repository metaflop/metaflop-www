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
  plugin :timestamps

  def before_create
    self.short = SecureRandom.urlsafe_base64[0, 10]
  end

  # we need to manually convert the params property to yaml
  # in order for the finder to work
  def self.find(properties)
    # we only want to modify the hash values for `find`,
    # not for a potential `create` afterwards.
    find_properties = properties.dup

    if find_properties[:params]
      find_properties[:params] = YAML.dump(find_properties[:params])
    end

    super(find_properties)
  end
end
