require 'mail/check_delivery_params'

module MongoMailer
  module DeliveryMethods
    class MongoQueue
      include ::Mail::CheckDeliveryParams

      attr_accessor :settings

      def initialize(options = {})
        @settings = options.merge(return_response: true)
      end

      def deliver!(mail)
        check_delivery_params(mail)
        collection.insert({encoded: mail.encoded, uuid: get_uuid})
      end

      private

      def get_uuid
        ::SecureRandom.hex(8)
      end

      def collection
        @collection ||= ::MongoMailer::MailQueue.instance.collection
      end
    end
  end
end