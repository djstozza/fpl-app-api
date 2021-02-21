RSpec.configure do |config|
  config.before do
    ActiveJob::Base.queue_adapter = :test
  end
end
