class TestWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(x)
    puts "This is the test worker being exercised"
    puts "the argument is #{x}"
  end
end
