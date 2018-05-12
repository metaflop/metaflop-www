#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require 'spec_helper'
# needed as we include the sprockets helper
require './app'
require './app/views/news'

describe App::Views::News do
  subject do
    App::Views::News.new.tap do |news|
      settings = double(:settings, metafonts: { bespoke: {}, adjuster: {} })
      allow(news).to receive(:settings).and_return(settings)
    end
  end

  context '#images' do
    let(:images) { subject.images }

    it 'returns an array of 12 adjuster images' do
      images.count { |x| x.include?('adjuster') }.should == 12
    end

    it 'returns an array of 12 bespoke images' do
      images.count { |x| x.include?('bespoke') }.should == 12
    end

    it 'returns the correct file path' do
      images.first.should =~ %r(^/assets/helloworld)
    end

    it 'returns one of each sequence number' do
      images.count { |x| x =~ /-01-/ }.should == 2
      images.count { |x| x =~ /-02-/ }.should == 2
      images.count { |x| x =~ /-03-/ }.should == 2
      images.count { |x| x =~ /-04-/ }.should == 2
      images.count { |x| x =~ /-05-/ }.should == 2
      images.count { |x| x =~ /-06-/ }.should == 2
      images.count { |x| x =~ /-07-/ }.should == 2
      images.count { |x| x =~ /-08-/ }.should == 2
      images.count { |x| x =~ /-09-/ }.should == 2
      images.count { |x| x =~ /-10-/ }.should == 2
      images.count { |x| x =~ /-11-/ }.should == 2
      images.count { |x| x =~ /-12-/ }.should == 2
    end
  end
end
