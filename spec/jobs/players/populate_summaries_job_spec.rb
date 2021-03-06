require 'rails_helper'

RSpec.describe Players::PopulateSummariesJob do
  it 'triggers the populate service' do
    expect(Players::PopulateSummaries).to receive(:call)

    expect { described_class.perform_now }.to enqueue_job(Leagues::ProcessFplTeamListsJob)
  end
end
