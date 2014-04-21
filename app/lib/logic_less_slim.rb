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
    begin
      require "./app/views/#{template}"
    rescue LoadError
      raise Error::TemplateNotFound.new
    end

    @view_model = "App::Views::#{template.to_s.camelize}".constantize.new

    # custom template set on class
    unless @view_model.class.template.nil?
      template = @view_model.class.template
    end

    # copy instance variables set in sinatra to the view
    instance_variables.each do |name|
      @view_model.instance_variable_set(name, instance_variable_get(name))
    end

    options = { :layout => layout, :dictionary => 'self.view_model' }

    if respond_to? :render, true
      content = render :slim, template, options

      if http_caching
        set_http_cache(content)
      end

      content
    else
      require 'slim'
      require 'tilt'
      Tilt.new("./app/views/#{template}.slim", options).render(self)
    end
  end
end
