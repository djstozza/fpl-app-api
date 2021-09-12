require 'rails_helper'

RSpec.describe Rounds::ProcessJob do
  it 'triggers the populate service' do
    expect(Rounds::Populate).to receive(:call)

    expect { described_class.perform_now }.to enqueue_job(Leagues::ProcessFplTeamListsJob)
  end
end
