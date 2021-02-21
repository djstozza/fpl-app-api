require 'rails_helper'

RSpec.describe Rounds::Populate, type: :service do
  describe '#call' do
    before do
      stub_request(:any, 'https://fantasy.premierleague.com/api/bootstrap-static/')
        .and_return(
          status: 200,
          body: file_fixture('bootstrap_static.json').read,
          headers: { 'Content-Type'=> 'application/json' },
        )
    end

    it 'creates round enrolments' do
      expect { described_class.call }.to change { Round.count }.from(0).to(3)
      expect(Round.first.attributes).to include(
        'name' => 'Gameweek 1',
        'finished' => true,
        'data_checked' => true,
        'is_previous' => false,
        'is_current' => false,
        'is_next' => false,
      )
    end

    it 'updates existing round enrolments' do
      round = build(:round, name: 'Gameweek 1', finished: false, external_id: 1)
      round.save

      expect { described_class.call }
        .to change { round.reload.finished }.from(false).to(true)
    end
  end
end
