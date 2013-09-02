module MongoMailer
  class MailQueue
    include Singleton
    include MongoMailer::HasMongoCollection

    MAX_RETIRES_COUNT = 5

    def find_and_deliver!
      item = get_oldest
    
      return unless item

      deliver!(item)
    end

    def get_oldest
      collection.find_and_modify(
        query: { invalid: nil },
        remove: true,
        sort: { :'$natural' => 1 })
    end

    def invalid_items
      collection.all(
        { invalid: true },
        sort: { :'$natural' => 1 })
    end

    def clear_invalid_items!
      collection.remove({ invalid: true })
    end

    private

    def deliver!(item)
      begin
        ::MongoMailer::FinalDeliverer.new(item['encoded']).deliver!
        collection.remove(item)
        return true
      rescue => e
        configuration.log_error(e)
        item['retries_count'] = (item['retries_count'] || 0) + 1
        item['invalid'] = true if item['retries_count'] > MAX_RETIRES_COUNT
        collection.insert(item)
        return false
      end
    end
  end
end