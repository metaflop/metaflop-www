#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require 'slim/logic_less'

# mixin for sinatra app
#
# provides a slim renderer that sets the template and view model from
# the views directory
#
# it can also be used for views that need to render a partial
module LogicLessSlim
  attr_reader :view_model

  # set the corresponding view model class to the slim view
  def slim(template, layout: true, http_caching: true)
    load_template(template)

    set_view_model(template)
    template = get_template(template)

    assign_instance_variables_to_view

    render_template(template, layout, http_caching)
  end

  private

  def load_template(template)
    require "./app/views/#{template}"
  rescue LoadError
    raise Metaflop::Error::TemplateNotFound.new
  end

  def set_view_model(template)
    @view_model = "App::Views::#{template.to_s.camelize}".constantize.new
  end

  def get_template(template)
    # get the custom template set on class
    @view_model.class.template || template
  end

  def assign_instance_variables_to_view
    # copy instance variables set in sinatra to the view
    instance_variables.each do |name|
      @view_model.instance_variable_set(name, instance_variable_get(name))
    end
  end

  def render_template(template, layout, http_caching)
    options = { layout: layout, dictionary: 'self.view_model' }

    if respond_to? :render, true
      render_native(template, options, http_caching)
    else
      render_tilt(template, options)
    end
  end

  def render_native(template, options, http_caching)
    # `render` needs a symbol, but it's safe here
    # (no symbol dos) as above the check
    # (see `#load_template`) returns if an invalid
    # template name is provided
    content = render :slim, template.to_sym, options

    if http_caching
      set_http_cache(content)
    end

    content
  end

  def render_tilt(template, options)
    require 'slim'
    require 'tilt'
    Tilt.new("./app/views/#{template}.slim", options).render(self)
  end
end
