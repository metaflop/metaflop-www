require 'sinatra'
require 'sinatra/reloader' if development?

get '/' do
    File.read('index.html')
end

get '/preview/:type' do |type|
    mf = Metafont.new 
    method = "preview_#{type}"
    if mf.respond_to? method
        [200, { 'Content-Type' => 'image/gif' }, mf.method("preview_#{type}").call]
    else
        [404, { 'Content-Type' => 'text/html' }, "The preview type could not be found"]
    end
end

class Metafont
    def initialize
    
    end

    def preview_single
        # hide all output but the last one, which returns the image
        `cd mf > /dev/null && mf adj.mf > /dev/null && gftodvi adj.2602gf > /dev/null && dvisvgm -TS0.75 -M16 --bbox=min -n adj.dvi > /dev/null && convert -trim adj.svg gif:-`
    end
end
