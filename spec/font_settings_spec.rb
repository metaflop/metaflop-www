#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './lib/font_settings'

describe FontSettings do
  context '#chars' do
    before do
      @chars = FontSettings.new.chars
    end

    it 'returns a hash with char categories' do
      @chars.keys.length.should > 0
    end

    it 'returns a hash with 26 upper case chars' do
      @chars[:uc].length == 26
    end

    it 'returns char names without ending' do
      @chars[:lc][0].should == 'a'
    end
  end
end
