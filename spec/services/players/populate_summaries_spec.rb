require 'rails_helper'

RSpec.describe Players::PopulateSummaries, type: :service do
  describe 'call' do
    it 'enqueues Players::PopulateSummaryJob for each player' do
      player1 = create :player
      player2 = create :player

      expect { described_class.call }
        .to have_enqueued_job(Players::PopulateSummaryJob).with(player1.id)
        .and have_enqueued_job(Players::PopulateSummaryJob).with(player2.id)
    end
  end
end
