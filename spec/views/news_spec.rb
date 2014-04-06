#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './views/news'

describe App::Views::News do
  subject { App::Views::News.new }

  context '#images' do
    let(:images) { subject.images }

    it 'returns an array of 12 adjuster images' do
      images.count { |x| x.include?('adjuster') }.should == 12
    end

    it 'returns an array of 12 bespoke images' do
      images.count { |x| x.include?('bespoke') }.should == 12
    end

    it 'returns the correct file path' do
      images.first.should =~ %r(^/img/helloworld)
    end

    it 'returns one of each sequence number' do
      images[0].should =~ /01/
      images[1].should =~ /02/
      images[2].should =~ /03/
      images[3].should =~ /04/
      images[4].should =~ /05/
      images[5].should =~ /06/
      images[6].should =~ /07/
      images[7].should =~ /08/
      images[8].should =~ /09/
      images[9].should =~ /10/
      images[10].should =~ /11/
      images[11].should =~ /12/

      images[12].should =~ /01/
      images[13].should =~ /02/
      images[14].should =~ /03/
      images[15].should =~ /04/
      images[16].should =~ /05/
      images[17].should =~ /06/
      images[18].should =~ /07/
      images[19].should =~ /08/
      images[20].should =~ /09/
      images[21].should =~ /10/
      images[22].should =~ /11/
      images[23].should =~ /12/
    end
  end
end
