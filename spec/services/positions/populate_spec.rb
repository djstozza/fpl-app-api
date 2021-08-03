require 'rails_helper'

RSpec.describe Positions::Populate, type: :service do
  include StubRequestHelper

  describe '#call' do
    before { stub_bootstrap_static_request }

    it 'creates positions' do
      expect { described_class.call }.to change(Position, :count).from(0).to(4)
      expect(Position.first.attributes).to include(
        'external_id' => 1,
        'plural_name' => 'Goalkeepers',
        'plural_name_short' => 'GKP',
        'singular_name' => 'Goalkeeper',
        'singular_name_short' => 'GKP',
        'squad_select' => 2,
        'squad_min_play' => 1,
        'squad_max_play' => 1,
      )
    end

    it 'updates existing positions' do
      position = build(:position, singular_name_short: 'DEF', external_id: 1)
      position.save

      expect { described_class.call }
        .to change { position.reload.singular_name_short }.from('DEF').to('GKP')
    end
  end
end
