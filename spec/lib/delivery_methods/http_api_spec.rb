require File.expand_path('../../../spec_helper', __FILE__)

describe MongoMailer::DeliveryMethods::HttpAPI do
  
  describe 'initialize' do
    let(:new_record) { described_class.new(options) }

    context 'url without scheme' do
      let(:options) { {api_url: 'infakt.pl'} }
      specify {
        lambda { new_record }.should raise_error(URI::InvalidURIError)
      }
    end
    context 'url without valid host' do
      let(:options) { {api_url: 'kielbasa'} }
      specify {
        lambda { new_record }.should raise_error(URI::InvalidURIError)
      }
    end
    context 'no url' do
      let(:options) { {} }
      specify {
        lambda { new_record }.should raise_error(URI::InvalidURIError)
      }
    end
    context 'valid options' do
      let(:options) { { api_url: 'http://mailer.example.com' } }
      specify {
        new_record.client.should be_kind_of(described_class::Client)
        new_record.client.http.should be_kind_of(Excon::Connection)
      }
    end
  end

  describe '#deliver!' do
    let(:subject) { described_class.new({ api_url: 'http://127.0.0.1:5000' }) }
    let(:mail) { Mail.new(from: 'joe@infakt.pl', to: 'joe@infakt.pl', subject: 'Hello') }
    let(:body) { {:you => 'got me'}.to_json }
    let(:response) { { 'message' => { 'id' => '666' }} }
    
    context "successful response" do
      before do
        subject.client.http.should_receive(:post).with({
            headers: described_class::Client::DEFAULT_HEADERS,
            path: described_class::Client::API_PATH,
            body: { mail: { encoded: mail.encoded } }.to_json
          }).and_return(double(:body => response.to_json, :status => 200, :headers => {}))
      end
      specify { subject.deliver!(mail).should == response }
    end

    context "failure response" do
      before do
        subject.client.http.should_receive(:post).and_return(double(:status => 500, :body => 'error'))
      end
      specify {
        lambda {
          subject.deliver!(mail)
        }.should raise_error(described_class::Client::FailureResponse)
      }
    end

    context 'invalid mail' do
      before do
        subject.should_receive(:client).never
      end
      specify {
        lambda {
          subject.deliver!(Mail.new)
        }.should raise_error(ArgumentError)
      }
    end
  end
end