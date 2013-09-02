require File.expand_path('../../../spec_helper', __FILE__)

describe MongoMailer::FinalDeliverer do
  let(:mail) { Mail.new(from: 'joe@infakt.pl', to: 'joe@infakt.pl', subject: 'Hello') }
  let(:subject) { described_class.new(mail.encoded) }
  let(:test1_mails) { MongoMailer::DeliveryMethods::Test1Mailer.deliveries }
  let(:test2_mails) { MongoMailer::DeliveryMethods::Test2Mailer.deliveries }

  after {
    test1_mails.clear
    test2_mails.clear
  }

  subject { described_class.new(mail) }

  describe '#deliver!' do
    context 'with successful base delivery' do
      before { 
        MongoMailer::DeliveryMethods::Test2Mailer.any_instance.should_receive(:deliver!).never
        subject.counter.should_receive(:increment).with(:base)
        subject.deliver!
      }
      specify {
        test1_mails.size.should == 1
        test2_mails.size.should == 0
      }
    end
    context 'with failure base delivery' do
      before {
        MongoMailer::DeliveryMethods::Test1Mailer.any_instance.should_receive(:deliver!).and_raise(ArgumentError)
        subject.counter.should_receive(:increment).with(:emergency)
        subject.deliver!
      }
      specify {
        test1_mails.size.should == 0
        test2_mails.size.should == 1
      }
    end
  end
end