module MongoMailer
  module HasMongoCollection
    def self.included(klass)
      klass.send :extend, ClassMethods
      klass.send :include, InstanceMethods
    end

    module InstanceMethods
      def collection
        self.class.collection
      end

      def configuration
        self.class.configuration
      end
    end

    module ClassMethods
      def collection_name
        @collection_name ||= self.name.demodulize.underscore.pluralize
      end

      def collection
        @collection ||= Configuration.instance.mongodb.collection(collection_name)
      end

      def configuration
        Configuration.instance
      end
    end
  end
end