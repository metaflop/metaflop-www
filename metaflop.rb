require 'sinatra'
require 'sinatra/reloader' if development?
require 'sass'

enable :sessions
set :logging, :true if development?

get '/' do
    session[:id] ||= SecureRandom.urlsafe_base64

    File.read('index.html')
end

get '/assets/css/screen.scss' do
    scss :screen
end

get '/preview/:type' do |type|
    # map all query params
    args = { :out_dir => "/tmp/metaflop/#{session[:id]}" }
    Metafont::VALID_OPTIONS_KEYS.each do |key|
        # query params come in with dashes -> replace by underscores to match properties
        param = params[key.to_s.gsub("_", "-")]
        args[key] = param if param && !param.empty?
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
        :out_dir,
        :char_number,
        :text,

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
    
    # the mapping between the defined params in the mf file and this class' properties
    MF_MAPPINGS = {
        'u#' => :unit_width,
        'cap#' => :cap_height,
        'mean#' => :mean_height,
        'bar' => :bar_height,
        'asc#' => :ascender_height,
        'desc#' => :descender_height,
        'incx' => :horizontal_increase,
        'incy' => :vertical_increase,
        'superness' => :superness,
        'px#' => :pen_x,
        'py#' => :pen_y,
        'cont' => :contrast
    }
    
    attr_accessor *VALID_OPTIONS_KEYS
    
    # initialize with optional options defined in VALID_OPTIONS_KEYS
    def initialize(args)
        args = options.merge(args)
        VALID_OPTIONS_KEYS.each do |key|
            instance_variable_set("@#{key}".to_sym, args[key])
        end
        
        # defaults
        @out_dir ||= '.'
        Dir.mkdir(@out_dir) unless File.directory?(@out_dir)
        
        @char_number ||= 1
    end

    # returns an gif image for a single character preview
    def preview_single    
        char_number = @char_number.to_s.rjust(2, '0')
        generate(nil, 'gftodvi adj.2602gf', char_number)
    end
    
    def preview_typewriter
        generate(%Q{cp *.mf #{@out_dir}}, %Q{echo "#{mf_args}" > adj.mf && latex -output-format=dvi -jobname=adj "\\\\documentclass[a4paper]{report} \\begin{document} \\pagestyle{empty} \\font\\big=adj at 20pt \\noindent \\big \\begin{flushleft}#{@text} \\end{flushleft} \\end{document}"})
    end
    
    def mf_args
        if !@mf_args
            @mf_args = File.readlines("mf/adj.mf")
                .delete_if do |x|            # remove comment and empty lines
                    stripped = x.strip
                    stripped == '' || stripped[0] == '%'
                end
                .map do |x|                  # remove comments at the end of the line
                    pair = x[/([^%]+)/, 0].strip
                    splits = pair.split(':=')
                    if (splits.length == 2)
                        # replace the default value from the file if we have a value set for the parameter
                        mapping = MF_MAPPINGS[splits[0]]
                        value = mapping ? send(mapping) : nil
                        if (value && !value.empty?)
                            pair = splits[0] + ':=' + splits[1].gsub(/[\d\/\.]+/, value)
                        end
                    end
                    pair
                end
                .join
        end
        
        @mf_args
    end
    
    def generate(pre, post, char_number = nil)
        pre = "#{pre} &&" if pre
        
        if char_number
            svg_name = "adj-#{char_number}.svg"
        else
            svg_name = "adj.svg"
            char_number = "01"
        end
    
        command = %Q{cd mf > /dev/null && 
                     mf -halt-on-error -jobname=adj -output-directory=#{@out_dir} \\\\"#{mf_args}" > /dev/null && 
                     #{pre}
                     cd #{@out_dir} && 
                     #{post} > /dev/null && 
                     dvisvgm -TS0.75 -M16 --bbox=min -n -p #{char_number} adj.dvi > /dev/null && 
                     convert -trim +repage -resize 'x315' #{svg_name} gif:-}
                     
        puts command
        
        # hide all output but the last one, which returns the image
        `#{command}`
    end
    
    def options
        options = {}
        VALID_OPTIONS_KEYS.each{ |k| options[k] = send(k) }
        options
    end
end
