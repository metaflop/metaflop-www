#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './lib/metaflop.rb'

describe Metaflop do
  context '#preview_y_offset' do
    [
      { :category => :cap, :value => 0 },
      { :category => :capo, :value => -2.0 },
      { :category => :mean, :value => 4.0 },
      { :category => :meano, :value => 2.0 },
      { :category => :asco, :value => 2.0 },
      { :category => :asc, :value => 4.0 }
    ].each do |x|
      it 'category #{x[:category]} returns correct offset' do
        mf = Metaflop.new :char_number => 1, :box_height => 1, :overshoot => 2,
          :cap_height => 5, :mean_height => 1, :ascender_height => 1
        mf.font_parameters.mean_height.unit = 'ht#'
        mf.settings = { :preview_height => 1, :glyph_categories => { 0 => x[:category] } }
        mf.preview_y_offset.should == x[:value]
      end
    end

    it 'raises an exception on non existing category' do
      mf = Metaflop.new
      mf.settings = { :preview_height => 1, :glyph_categories => { 0 => :asdf } }
      expect {mf.preview_y_offset}.to raise_error(ArgumentError)
    end
  end
end
