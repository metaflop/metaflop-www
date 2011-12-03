require 'sinatra'
require 'sinatra/reloader' if development?

get '/' do
    File.read('index.html')
end

get '/preview/:type' do |type|
    # map all query params
    args = {}
    Metafont::VALID_OPTIONS_KEYS.each do |key|
        # query params come in with dashes -> replace by underscores to match properties
        param = params[key.to_s.gsub("_", "-")]
        args[key] = param if param
    end
    
    mf = Metafont.new(args)
    method = "preview_#{type}"
    if mf.respond_to? method
        [200, { 'Content-Type' => 'image/gif' }, mf.method("preview_#{type}").call]
    else
        [404, { 'Content-Type' => 'text/html' }, "The preview type could not be found"]
    end
end

class Metafont
    
    # these options can be set when instantiating this class
    VALID_OPTIONS_KEYS = [
        :box_height,
        :unit_width,
        :cap_height,
        :mean_height,
        :bar_height,
        :ascender_height,
        :descender_height,
        :horizontal_increase,
        :vertical_increase,
        :superness,
        :pen_type,
        :mode,
        :pen_x,
        :pen_y,
        :pen_angle,
        :contrast
    ]
    
    attr_accessor *VALID_OPTIONS_KEYS

    # initialize with optional options defined in VALID_OPTIONS_KEYS
    def initialize(args)
        args = options.merge(args)
        VALID_OPTIONS_KEYS.each do |key|
            instance_variable_set("@#{key}".to_sym, args[key])
        end
        
        @out_dir ||= '.'
    end

    # returns an gif image for a single character preview
    def preview_single
        mf_args = File.readlines("mf/adj.mf")
            .delete_if do |x|            # remove comment and empty lines
                stripped = x.strip
                stripped == '' || stripped[0] == '%'
            end
            .map do |x|                  # remove comments at the end of the line
                x[/([^%]+)/, 0]
            end
            .join
            
        # hide all output but the last one, which returns the image
        `cd mf > /dev/null && 
         mf -jobname=adj -output-directory=#{@out_dir} \\\\"#{mf_args}" > /dev/null && 
         gftodvi #{@out_dir}/adj.2602gf > /dev/null && 
         dvisvgm -TS0.75 -M16 --bbox=min -n -p 28 #{@out_dir}/adj.dvi > /dev/null && 
         convert -trim +repage #{@out_dir}/adj-28.svg gif:-`
    end
        
    def options
        options = {}
        VALID_OPTIONS_KEYS.each{ |k| options[k] = send(k) }
        options
    end
end
