require 'mail/check_delivery_params'

module MongoMailer
  module DeliveryMethods
    module CommonTestMailer
      def self.included(klass)
        klass.send :include, ::Mail::CheckDeliveryParams
        klass.send :extend,  ClassMethods
        klass.send :include, InstanceMethods
        klass.send :attr_accessor, :settings
      end

      module InstanceMethods         
        def initialize(*args)
          @settings = {}
        end
         
        def deliver!(mail)
          check_delivery_params(mail)
          self.class.deliveries << mail
        end
      end

      module ClassMethods
        def deliveries
          @deliveries ||= []
        end

        def deliveries=(val)
          @deliveries = val
        end
      end
    end

    class Test1Mailer
      include CommonTestMailer
    end    

    class Test2Mailer
      include CommonTestMailer
    end
  end
end