require 'database_cleaner'

#
# Use database cleaner instead of AR transactional_fixtures because it lets
# us use multiple connections in our specs
#
RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.prepend_before(:example, no_transaction: true) do
    @database_cleaner_strategy = :truncation
  end

  config.before do
    DatabaseCleaner.strategy = @database_cleaner_strategy || :transaction
    DatabaseCleaner.start
  end

  config.append_after do
    DatabaseCleaner.clean
  end
end
