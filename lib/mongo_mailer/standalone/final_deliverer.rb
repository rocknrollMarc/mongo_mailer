module MongoMailer
  class FinalDeliverer
    attr_reader :mail, :configuration, :counter
  
    def initialize(encoded)
      @encoded = encoded
      @mail    = Mail.new(@encoded)
      @configuration = Configuration.instance
      @counter       = DeliveriesCounter.instance
    end

    def logger
      Configuration.instance.logger
    end

    def deliver!
      begin
        configuration.logger.info("[delivery][base] #{mail.inspect}")
        mail.delivery_method *base_delivery
        mail.deliver!
        counter.increment(:base)
      rescue => e
        configuration.log_error(e)
        configuration.logger.warn("[delivery][emergency] #{mail.inspect}")
        mail.delivery_method *emergency_delivery
        mail.deliver!
        counter.increment(:emergency)
      end
    end

    def base_delivery
      Configuration.instance.base_delivery
    end

    def emergency_delivery
      Configuration.instance.emergency_delivery
    end
  end
end