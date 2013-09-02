require File.expand_path('../../../spec_helper', __FILE__)

describe MongoMailer::MailQueue do
  let(:mail) { Mail.new(from: 'joe@infakt.pl', to: 'joe@infakt.pl', subject: 'Hello', body: 'hello') }

  let(:item1) { {encoded: mail.encoded, uuid: ::SecureRandom.hex} }
  let(:item2) { {encoded: mail.encoded, uuid: ::SecureRandom.hex} }
  let(:deliveries) { MongoMailer::DeliveryMethods::Test1Mailer.deliveries }
  
  before {
    subject.collection.remove
    MongoMailer::DeliveryMethods::Test1Mailer.deliveries.clear
  }
  
  subject { described_class.instance }

  describe '#get_oldest' do
    before {
      subject.collection.insert(item1)
      sleep(0.01)
      subject.collection.insert(item2)
    }
    specify {
      subject.get_oldest['uuid'].should == item1[:uuid]
    }
  end

  describe '#find_and_deliver!' do
    context 'with item in queue' do
      before {
        subject.collection.insert(item1)
        subject.collection.insert(item2)
      }
      context 'success' do
        specify {
          subject.find_and_deliver!.should == true
          deliveries.size.should == 1
        }
      end
      context 'failure' do
        before {
          MongoMailer::FinalDeliverer.should_receive(:new).and_raise(ArgumentError.new)
        }
        specify {
          subject.find_and_deliver!.should == false
          deliveries.size.should == 0
        }
      end
    end
    context 'without item in queue' do
      context 'success' do
        specify {
          subject.find_and_deliver!.should be_nil
          deliveries.size.should == 0
        }
      end
    end
  end
end