module Resque
  # This is the module that should be included in your worker to make it's jobs FutureJob instances.
  module Future
    # Wraps the perform method, saving the return statement for the future job.
    # @see ResqueFuture::FutureJob
    def around_perform_future(uuid, *args, &block)
      job = ResqueFuture::FutureJob.get(@queue, uuid)
      job.result = yield
    end
  end
end