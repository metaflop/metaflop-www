# encoding: UTF-8

#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './lib/facebook.rb'

# don't try to read from abstract adapter
module DataMapper
  module Model
    def first(*args)
    end
  end
end

# ignore storing of a new record
module DataMapper
  module Adapters
    class AbstractAdapter
      def create(resources)
      end
    end
  end
end

describe Facebook do
  context '#import_news' do
    before do
      DataMapper.setup(:default, "abstract::")
      DataMapper.finalize

      @fb = Facebook.new 'bogus_token'
      @fb.stub(:fetch => Marshal.load(File.read('spec/fixtures/posts.dump')))
    end

    context 'post body has an implicit title line' do
      it 'title in post body should become news title' do
        post = @fb.import_news[0]
        post.title.should == 'kulturbüro newsletter'
        post.text.should =~ /an animated newsletter/
      end
    end

    context 'post body has no implicit title line' do
      it 'name should be title' do
        post = @fb.import_news[1]
        post.title.should == 'font: adjuster'
        post.text.should =~ /mf adjuster is a font with/
      end
    end
  end
end
