#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require 'spec_helper'
require './app/lib/web_font'

describe WebFont do
  describe '#zip' do
    it 'adds each file' do
      Zip::File.any_instance.should_receive(:add).
        with('Bespoke-abcd.eot', '/tmp/metaflop/bespoke/font.eot')
      Zip::File.any_instance.should_receive(:add).
        with('Bespoke-abcd.woff', '/tmp/metaflop/bespoke/font.woff')
      Zip::File.any_instance.should_receive(:add).
        with('Bespoke-abcd.ttf', '/tmp/metaflop/bespoke/font.ttf')
      Zip::File.any_instance.should_receive(:add).
        with('Bespoke-abcd.svg', '/tmp/metaflop/bespoke/font.svg')
      Zip::File.any_instance.should_receive(:add).
        with('Bespoke-abcd_sample.html', '/tmp/metaflop/bespoke/Bespoke-abcd_sample.html')
      Zip::File.any_instance.should_receive(:add).
        with('license.gpl', 'bin/license.gpl')
      Zip::File.any_instance.should_receive(:add).
        with('license.ofl', 'bin/license.ofl')

      font_settings = FontSettings.new(
        fontface: 'Bespoke',
        font_hash: 'abcd',
        out_dir: '/tmp/metaflop/')
      webfont = WebFont.new(font_settings)
      webfont.zip
    end
  end
end
