require 'rails_helper'

RSpec.describe SqlQuery, type: :model do
  it 'raises a Query not found error if not found' do
    path = Rails.root.join('app/queries/foo.sql')

    expect { described_class.results('foo') }
      .to raise_error(
        RuntimeError,
        "Query not found `foo`: can't read file #{path}"
      )
  end
end
