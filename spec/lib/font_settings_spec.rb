#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require 'spec_helper'
require './app/lib/font_settings'

describe FontSettings do
  context '#to_hash' do
    it 'returns a hash of the instance variables' do
      Time.stub_chain(:new, :year).and_return(2001)

      FontSettings.new.to_hash.should == {
        font_hash: nil,
        fontface: 'Bespoke',
        out_dir: '/tmp/metaflop/bespoke',
        year: 2001
      }
    end
  end
end
