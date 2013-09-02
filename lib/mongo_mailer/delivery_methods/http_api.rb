require 'mail/check_delivery_params'

module MongoMailer
  module DeliveryMethods
    class HttpAPI
      class Client
        class FailureResponse < StandardError; end
      
        TIMEOUT_IN_SECONDS = 120
        DEFAULT_HEADERS = { 'Content-Type' => 'application/json' }
        API_PATH = '/api/mails.json'
      
        attr_reader :http, :url

        def initialize(api_url)
          @url = api_url
          @http = ::Excon.new(api_url,
            retry_limit: 2,
            connect_timeout: TIMEOUT_IN_SECONDS,
            read_timeout: TIMEOUT_IN_SECONDS)
        end

        def post(mail)
          body         = { mail: { encoded: mail.encoded } }.to_json
          req_options = { path: '/api/mails.json', headers: DEFAULT_HEADERS, body: body }

          response = http.post(req_options)
          ensure_successfull_response!(req_options, response)

          return JSON.parse(response.body)
        end

        private

        def ensure_successfull_response!(req_options, response)
          if response.status > 299
            raise FailureResponse.new("Got status: #{response.status} from: #{url} with request: #{req_options.inspect} and r\n *#{response.body.to_s.truncate(200)}*!")
          end
        end
      end

      include ::Mail::CheckDeliveryParams

      attr_accessor :settings, :client

      def initialize(options = {})
        @settings = options.merge(return_response: true)
        @uri = URI.parse(options[:api_url])
        raise URI::InvalidURIError.new("bad url: #{@uri}") if @uri.host.nil? || @uri.scheme.nil?
        @client = Client.new(@uri.to_s)
      end

      def deliver!(mail)
        check_delivery_params(mail)
        client.post(mail)
      end
    end
  end
end