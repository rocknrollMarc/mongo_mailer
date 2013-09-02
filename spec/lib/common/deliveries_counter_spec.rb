require File.expand_path('../../../spec_helper', __FILE__)

describe MongoMailer::DeliveriesCounter do
  subject { described_class.instance }

  before(:all) {
    described_class.instance.collection.drop
  }
  
  describe '#increment' do
    before {
      subject.increment(:base)
      subject.increment(:base)
      subject.increment(:emergency)
    }
    it { 
      subject.by_type(:base)['value'].should == 2
      subject.by_type(:emergency)['value'].should == 1
      subject.all.size.should == 2
    }
  end
end