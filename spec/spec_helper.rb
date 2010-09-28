$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require "resque"
require 'resque_future'
require 'rspec'

Resque.redis = "redis://localhost/1"

class SomeWorker
  extend Resque::Future
  @queue = :some_queue
  
  def self.perform(uuid, some_arg)
    return true
  end
end

RSpec.configure do |config|
  config.before(:each) do
    Resque.redis.flushdb
  end
end
