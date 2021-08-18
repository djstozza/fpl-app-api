require 'rails_helper'

RSpec.describe Leagues::ProcessFplTeamListsJob do
  let!(:league1) { create :league, :live }
  let!(:league2) { create :league }

  it 'triggers the scoring service for live leagues' do
    expect_any_instance_of(Leagues::ProcessFplTeamLists).to receive(:call)

    described_class.perform_now
  end
end
