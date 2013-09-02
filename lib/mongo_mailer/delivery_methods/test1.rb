require 'mail/check_delivery_params'

module MongoMailer
  module DeliveryMethods
    class Test1Mailer
      include ::Mail::CheckDeliveryParams
    
      def self.deliveries
        @@deliveries ||= []
      end

      def self.deliveries=(val)
        @@deliveries = val
      end

      def initialize(*args)
        @settings = {}
      end

      attr_accessor :settings

      def deliver!(mail)
        check_delivery_params(mail)
        self.class.deliveries << mail
      end
    end
  end
end