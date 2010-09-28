unless defined?(Resque)
  puts "ResqueFuture requires Resque, please require \"resque\""
  exit(1)
end

require "resque_future/future_job"
require "resque/future"

# Extend Resque namespace to add enqueue_future method.
module Resque
  # Same as enqueue excepts it return a FutureJob allowing for later querying the return
  # value of the processed job.
  def enqueue_future(klass, *args)
    enqueue_future_with_uuid(nil, klass, *args)
  end
  
  # Same as enqueue_future excepts it allows manually setting the UUID for the future object.
  def enqueue_future_with_uuid(uuid, klass, *args)
    ResqueFuture::FutureJob.create(queue_from_class(klass), uuid, klass, *args)
  end
  
  # Get a future job
  def get_future_job(uuid, klass)
    ResqueFuture::FutureJob.get(queue_from_class(klass), uuid)
  end
end