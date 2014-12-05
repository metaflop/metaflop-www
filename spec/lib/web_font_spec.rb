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
        with('Testfont-abcd.eot', '/tmp/metaflop/testfont/font.eot')
      Zip::File.any_instance.should_receive(:add).
        with('Testfont-abcd.woff', '/tmp/metaflop/testfont/font.woff')
      Zip::File.any_instance.should_receive(:add).
        with('Testfont-abcd.ttf', '/tmp/metaflop/testfont/font.ttf')
      Zip::File.any_instance.should_receive(:add).
        with('Testfont-abcd.svg', '/tmp/metaflop/testfont/font.svg')
      Zip::File.any_instance.should_receive(:add).
        with('Testfont-abcd_sample.html', '/tmp/metaflop/testfont/Testfont-abcd_sample.html')
      Zip::File.any_instance.should_receive(:add).
        with('license.gpl', 'bin/license.gpl')
      Zip::File.any_instance.should_receive(:add).
        with('license.ofl', 'bin/license.ofl')

      font_settings = FontSettings.new(
        fontface: 'Testfont',
        font_hash: 'abcd',
        out_dir: '/tmp/metaflop/')
      webfont = WebFont.new(font_settings)
      webfont.zip
    end
  end
end
