module MongoMailer
  class DeliveriesCounter
    include Singleton
    include ::MongoMailer::HasMongoCollection

    def increment(type)
      collection.update({ type: type }, { '$inc' => { value: 1 } }, {upsert: true})
    end

    def by_type(type)
      collection.find_one({type: type})
    end

    def all
      collection.find.to_a
    end
  end
end