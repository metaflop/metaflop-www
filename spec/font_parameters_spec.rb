#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './lib/font_parameters'

describe FontParameters do
  context '#initialize' do
    it 'no param value passed initializes with nil' do
      FontParameters.new.unit_width.should == FontParameter.new
    end

    it 'param value passed initializes with passed value' do
      FontParameters.new(:unit_width => '1.0').unit_width.should == FontParameter.new('1.0')
    end

    context 'with legacy params' do
      it 'pen_size is stored in pen_width' do
        FontParameters.new(:pen_size => '3.2').pen_width.should == FontParameter.new('3.2')
      end

      it 'pen_width is stored in pen_width' do
        FontParameters.new(:pen_width => '3.2').pen_width.should == FontParameter.new('3.2')
      end

      it 'non legacy param unit_width is stored in unit_width' do
        FontParameters.new(:unit_width => '3.2').unit_width.should == FontParameter.new('3.2')
      end
    end
  end

  context '#from_file' do
    it 'no param values passed initializes with default values' do
      params = FontParameters.new
      params.from_file
      params.unit_width.should_not be_nil
    end

    it 'param value passed initializes with passed value' do
      params = FontParameters.new :unit_width => '1.0'
      params.from_file
      params.unit_width.value.should == '1.0'
    end

    it 'param value passed default value is different than passed in value' do
      params = FontParameters.new :unit_width => '19.0'
      params.from_file
      params.unit_width.default.should_not == '19.0'
    end
  end

  context '#to_file' do
    it 'no passed in value, the original and new file are the same' do
      params = FontParameters.new({}, FontSettings.new(:out_dir => '/tmp/metaflop/spec'))
      params.to_file
      File.read('/tmp/metaflop/spec/bespoke/font.mf').should ==
        File.read('mf/metaflop-font-bespoke/font.mf')
    end

    it 'passed in value is in file' do
      params = FontParameters.new({ :unit_width => '1.0' }, FontSettings.new(:out_dir => '/tmp/metaflop/spec'))
      params.to_file
      File.read('/tmp/metaflop/spec/bespoke/font.mf').should include 'u#:=1.0pt#;'
    end
  end

  context '#instance_param' do
    it 'param key is instance variable name as symbol' do
      params = FontParameters.new(:unit_width => '1.0')
      params.instance_param(:unit_width).should == FontParameter.new('1.0')
    end

    it 'param key is instance variable name as string' do
      params = FontParameters.new(:unit_width => '1.0')
      params.instance_param('unit_width').should == FontParameter.new('1.0')
    end

    it 'param key is metafont variable name as symbol' do
      params = FontParameters.new(:unit_width => '1.0')
      params.instance_param('u#'.to_sym).should == FontParameter.new('1.0')
    end

    it 'param key is metafont variable name as string' do
      params = FontParameters.new(:unit_width => '1.0')
      params.instance_param('u#').should == FontParameter.new('1.0')
    end
  end

  context '#absolute_value' do
    it 'param has not super unit, get value itself' do
      params = FontParameters.new
      params.box_height = FontParameter.new('1.0', '1.0', 'pt#')
      params.unit_width = FontParameter.new('2.0', '2.0', 'pt#')
      params.absolute_value(:unit_width).should == 2.0
    end

    it 'param has super unit, get value times super-unit value' do
      params = FontParameters.new
      params.box_height = FontParameter.new('1.5', '1.5', 'pt#')
      params.unit_width = FontParameter.new('2.0', '2.0', 'ht#')
      params.absolute_value(:unit_width).should == 1.5 * 2.0
    end

    it 'param has no unit, get value itself' do
      params = FontParameters.new
      params.box_height = FontParameter.new('1.5', '1.5', 'pt#')
      params.pen_angle = FontParameter.new('1.0')
      params.absolute_value(:pen_angle).should == 1.0
    end
  end
end
