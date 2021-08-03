require 'support/database_cleaner'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  if config.files_to_run.many?
    config.before(:suite) do
      DatabaseCleaner.clean_with(:truncation)
      DatabaseCleaner.cleaning { FactoryBot.lint(traits: true) }

      puts RSpec::Core::Formatters::ConsoleCodes.wrap('✔︎ Linted factories', :success)
    end
  end
end

module FactoryBot
  module Strategy
    #
    # This is effectively a find or create strategy for factories. It is
    # particularly handy for reusing records in associations when you
    # don't care about the particular instance.
    #
    #     factory :widgets do
    #       association :owner, strategy: :default
    #     end
    #
    # It can also be used directly `widget = FactoryBot.default(:widget)`
    #
    class Default
      def initialize
        @create_strategy = FactoryBot.strategy_by_name(:create).new
      end

      def association(runner)
        runner.run
      end

      def result(evaluation)
        relation = evaluation.object.class
        relation.first or @create_strategy.result(evaluation)
      end
    end
  end

  register_strategy(:default, Strategy::Default)
end
