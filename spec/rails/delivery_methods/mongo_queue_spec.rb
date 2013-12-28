# encoding: utf-8
require File.expand_path('../../../spec_helper', __FILE__)
require 'mongo_mailer/rails'

ActionMailer::Base.delivery_method = :mongo_queue

class SampleMailer < ActionMailer::Base
  def sample
    opts = {
      from:    "system@infakt.kielbasa",
      to:      "joe@infakt.kielbasa",
      subject: "Sample Mailer Kiełbasa Test"
    }
    mail(opts) do |format|
      format.html { render :text => "Kiełbasa - #{Time.now}" }
    end
  end
end

describe MongoMailer::DeliveryMethods::MongoQueue do    
  before(:all) {
    MongoMailer::MailQueue.collection_name = "mongo_queue_#{SecureRandom.hex}"
  }
  describe '#deliver!' do
    let(:sent_mail1_id) { SampleMailer.sample.deliver! }
    let(:sent_mail2_id) { SampleMailer.sample.deliver! }
    specify {
      sent_mail1_id.should be_kind_of(BSON::ObjectId)
      sent_mail2_id.should be_kind_of(BSON::ObjectId)
      MongoMailer::MailQueue.instance.get_oldest['_id'].should == sent_mail1_id
    }
  end
end