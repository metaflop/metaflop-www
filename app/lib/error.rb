#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

class Metaflop
  module Error
    class Metafont < StandardError; end
    class TemplateNotFound < StandardError; end
  end
end
