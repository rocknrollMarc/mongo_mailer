require File.expand_path('../../spec_helper', __FILE__)

describe MongoMailer::Configuration do
  describe '.lookup_delivery_method' do
    subject { described_class.instance }
    let(:delivery_method) { subject.lookup_delivery_method(type) }
    
    context ":test1" do
      let(:type) { :test1 }
      it { delivery_method.should be_kind_of(Class) }
    end
    context ":test2" do
      let(:type) { :test2 }
      it { delivery_method.should be_kind_of(Class) }
    end
    context ":unknown" do
      let(:type) { :unknown }
      it { lambda { described_class.lookup_delivery_method(type) }.should raise_error }
    end
  end
end