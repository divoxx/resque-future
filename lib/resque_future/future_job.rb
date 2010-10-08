require "digest/sha2"
require "time"

module ResqueFuture
  # A FutureJob is a job schedule to run in the future that you still want to be able to
  # track it's result and status.
  class FutureJob < Resque::Job
    attr_reader :uuid
    
    # Override constructor to receive an UUID
    def initialize(queue, uuid, payload)
      @uuid = uuid || self.generate_uuid
      payload["args"].unshift(@uuid)
      super(queue, payload)
    end
  
    # Override Job.create method so that it returns a instance of FutureJob allowing
    # for late querying for the result.
    def self.create(queue, uuid, klass, *args)
      job = self.new(queue, uuid, 'class' => klass, 'args' => args)
      super(queue, klass, *args)
      job.persist
      job
    end
    
    # Query for a FutureJob using it's UUID
    def self.get(queue, uuid)
      self.new(queue, uuid, self.payload(uuid))
    end
    
    # Persist the job information into redis
    def persist
      redis.set(self.payload_key, encode(self.payload))
    end
    
    # Returns true/false if the job has been processed yet
    def ready?
      redis.exists(self.result_payload_key)
    end
    
    # Returns true/false whether it is waiting in the queue or being processed
    def processing?
      redis.exists(self.payload_key) && !ready?
    end
    
    # Returns the result for the job
    def result
      self.result_payload["result"] if self.result_payload
    end
    
    # Returns the time that the result was written to redis and the job finished processing.
    def finished_at
      Time.parse(self.result_payload["finished_at"]) if self.result_payload && self.result_payload["finished_at"]
    end
    
    # Sets the result for this job
    def result=(result_value)
      redis.set(result_payload_key, encode('result' => result_value, "finished_at" => Time.now.utc))
    end
    
  protected
    # Generate a unique identifier
    def generate_uuid
      Digest::SHA2.hexdigest("#{@queue}#{encode(payload)}#{Time.now.to_i}")
    end
    
    # Return the redis payload key for the given UUID
    def self.payload_key(uuid)
      "meta:#{uuid}:payload"
    end
    
    # Return the payload for the given UUID
    def self.payload(uuid)
      decode(redis.get(self.payload_key(uuid)))
    end
    
    # Return the redis payload key for this object
    def payload_key
      self.class.payload_key(@uuid)
    end
    
    # Return and cache the payload
    def payload
      @payload ||= (super || self.class.payload(@uuid))
    end

    # Return the redis result key for the given UUID
    def self.result_payload_key(uuid)
      "meta:#{uuid}:result_payload"      
    end
    
    # Return the result payload for the given UUID
    def self.result_payload(uuid)
      decode(redis.get(self.result_payload_key(uuid)))
    end

    # Return the redis result key for this object
    def result_payload_key
      self.class.result_payload_key(@uuid)
    end
    
    # Return and cache the result payload
    def result_payload
      @result_payload ||= self.class.result_payload(@uuid)
    end
  end
end