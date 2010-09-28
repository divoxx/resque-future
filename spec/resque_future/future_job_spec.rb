require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include ResqueFuture

describe FutureJob do
  before :each do
    @queue    = :some_queue
    @klass    = SomeWorker
    @uuid     = "some_uuid"
    @args     = [:some_argument]
    @job_mock = mock(:future_job, :persist => true)
  end
  
  describe "creating a future job" do
    def create_job
      FutureJob.create(@queue, @uuid, @klass, *@args)
    end
    
    it "should create a new instance" do
      FutureJob.should_receive(:new).with(@queue, @uuid, {"class" => @klass, "args" => @args}).and_return(@job_mock)
      create_job
    end
  end
  
  describe "instantiating a future job" do
    def instantiate_job
      FutureJob.new(@queue, @uuid, {"class" => @klass, "args" => @args})
    end
    
    it "should set attributes" do
      job = instantiate_job
      %w(queue payload uuid).should be_all { |attr| job.instance_variable_get("@#{attr}") }
    end
    
    it "should autogenerate uuid if not provided" do
      @uuid = nil
      job = instantiate_job
      job.uuid.should_not be_nil
      job.uuid.should_not eql("some_uuid")
    end
  end
  
  shared_examples_for "querying a processed job" do
    it "should be ready" do
      @job.should be_ready
    end
    
    it "should have a result" do
      @job.result.should_not be_nil
      @job.result.should be(true)
    end
    
    it "should have finished_at set" do
      @job.finished_at.should_not be_nil
      @job.finished_at.should be_instance_of(Time)
    end
  end
  
  describe "querying a processed job with same instance" do 
    before :each do
      @job = FutureJob.create(@queue, @uuid, @klass, *@args)
      @job.perform
    end

    it_should_behave_like "querying a processed job"
  end
  
  describe "querying a processed job with different instance" do
    before :each do
      orig_job = FutureJob.create(@queue, @uuid, @klass, *@args)
      orig_job.perform
      @job = FutureJob.get(@queue, @uuid)
    end

    it_should_behave_like "querying a processed job"
  end
  
  shared_examples_for "querying a unprocessed job" do
    it "should be ready" do
      @job.should_not be_ready
    end
    
    it "should have a result" do
      @job.result.should be_nil
    end
    
    it "should have finished_at set" do
      @job.finished_at.should be_nil
    end
  end
  
  describe "querying a unprocessed job with same instance" do 
    before :each do
      @job = FutureJob.create(@queue, @uuid, @klass, *@args)
    end

    it_should_behave_like "querying a unprocessed job"
  end
  
  describe "querying a unprocessed job with different instance" do
    before :each do
      orig_job = FutureJob.create(@queue, @uuid, @klass, *@args)
      @job = FutureJob.get(@queue, @uuid)
    end

    it_should_behave_like "querying a unprocessed job"
  end
end