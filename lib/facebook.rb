#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require 'fb_graph'
require './views/news'

class Facebook

  def initialize(access_token)
    @access_token = access_token
  end

  def fetch
    user = FbGraph::User.fetch('Metaflop', 
                               :access_token => @access_token)
    user.posts
  end

  def import_news
    fetch.delete_if {|x| x.type == 'status'}.map do |x|
      title = x.message.to_s[/(\A[^\n]+)\n\n/, 1]
      if title
        text = x.message[title.length..-1]
      else
        title = x.name
        text = x.message
      end

      App::Views::News.first_or_create(
        {:facebook_id => x.identifier},
        {:title => title, :text => text, :data => x,
          :published_at => x.created_time})
    end
  end
end
