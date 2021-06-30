require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "api/list_positions", :no_transaction, type: :request do

  let(:fpl_team_list) { create :fpl_team_list }

  let!(:list_position1) { create :list_position, :starting, :forward, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position2) { create :list_position, :starting, :midfielder, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position3) { create :list_position, :starting, :midfielder, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position4) { create :list_position, :starting, :defender, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position5) { create :list_position, :starting, :defender, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position6) { create :list_position, :starting, :defender, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position7) { create :list_position, :starting, :goalkeeper, fpl_team_list_id: fpl_team_list.id }
  let!(:list_position8) { create :list_position, :substitute_gkp, :goalkeeper, fpl_team_list_id: fpl_team_list.id }

  before { api.authenticate(fpl_team_list.fpl_team.owner) }

  describe 'GET /show' do
    context '3 forwards, 4 defenders, 3 midfielders' do
      let!(:list_position9) { create :list_position, :starting, :forward, fpl_team_list_id: fpl_team_list.id }
      let!(:list_position10) { create :list_position, :starting, :forward, fpl_team_list_id: fpl_team_list.id }
      let!(:list_position11) { create :list_position, :starting, :midfielder, fpl_team_list_id: fpl_team_list.id }
      let!(:list_position12) { create :list_position, :starting, :midfielder, fpl_team_list_id: fpl_team_list.id }
      let!(:list_position13) { create :list_position, :substitute_1, :midfielder, fpl_team_list_id: fpl_team_list.id }
      let!(:list_position14) { create :list_position, :substitute_2, :defender, fpl_team_list_id: fpl_team_list.id }
      let!(:list_position15) { create :list_position, :substitute_3, :defender, fpl_team_list_id: fpl_team_list.id }

      it 'shows valid potential substitutions' do
        # Subbing out a starting forward
        api.get(api_list_position_url(list_position1.id))
        # All substitutes can be subbed in
        expect(api.data['valid_substitutions']).to contain_exactly(
          list_position13.to_param,
          list_position14.to_param,
          list_position15.to_param,
        )

        # Subbing out a starting defender
        api.get(api_list_position_url(list_position4.id))
        # Can only sub in substitute defenders since there are only 3 starting defenders
        expect(api.data['valid_substitutions']).to contain_exactly(
          list_position14.to_param,
          list_position15.to_param,
        )

        # Subbing out the starting goalkeeper
        api.get(api_list_position_url(list_position7.id))
        # Can only sub in the substitute goalkeeper
        expect(api.data['valid_substitutions']).to contain_exactly(
          list_position8.to_param,
        )

        # Subbing in a the substitute goalkeeper
        api.get(api_list_position_url(list_position8.id))
        # Can only sub out the starting goalkeeper
        expect(api.data['valid_substitutions']).to contain_exactly(
          list_position7.to_param,
        )

        # Subbing in a substitute midfielder
        api.get(api_list_position_url(list_position13.id))
        # There are only 3 starting defenders so none of them can be subbed out
        expect(api.data['valid_substitutions']).to contain_exactly(
          list_position1.to_param,
          list_position2.to_param,
          list_position3.to_param,
          list_position9.to_param,
          list_position10.to_param,
          list_position11.to_param,
          list_position12.to_param,
        )
      end
    end

    context '1 forward, 5 midfielders, 4 defenders' do
      let!(:list_position9) { create :list_position, :starting, :midfielder, fpl_team_list_id: fpl_team_list.id }
      let!(:list_position10) { create :list_position, :starting, :midfielder, fpl_team_list_id: fpl_team_list.id }
      let!(:list_position11) { create :list_position, :starting, :midfielder, fpl_team_list_id: fpl_team_list.id }
      let!(:list_position12) { create :list_position, :starting, :defender, fpl_team_list_id: fpl_team_list.id }
      let!(:list_position13) { create :list_position, :substitute_1, :forward, fpl_team_list_id: fpl_team_list.id }
      let!(:list_position14) { create :list_position, :substitute_2, :forward, fpl_team_list_id: fpl_team_list.id }
      let!(:list_position15) { create :list_position, :substitute_3, :defender, fpl_team_list_id: fpl_team_list.id }

      it 'shows valid potential substitutions' do
        # Subbing out a starting forward
        api.get(api_list_position_url(list_position1.id))
        # Only substitute forwards can be subbed in since there is only one starting forward
        expect(api.data['valid_substitutions']).to contain_exactly(
          list_position13.to_param,
          list_position14.to_param,
        )

        # Subbing out a starting midfielder
        api.get(api_list_position_url(list_position2.id))
        # All substitutes can be subbed in
        expect(api.data['valid_substitutions']).to contain_exactly(
          list_position13.to_param,
          list_position14.to_param,
          list_position15.to_param,
        )

        # Subbing out the starting goalkeeper
        api.get(api_list_position_url(list_position7.id))
        # Can only sub in the substitute goalkeeper
        expect(api.data['valid_substitutions']).to contain_exactly(
          list_position8.to_param,
        )

        # Subbing in a substitute forward
        api.get(api_list_position_url(list_position14.id))
        # All starting outfielders can be subbed out
        expect(api.data['valid_substitutions']).to contain_exactly(
          list_position1.to_param,
          list_position2.to_param,
          list_position3.to_param,
          list_position4.to_param,
          list_position5.to_param,
          list_position6.to_param,
          list_position9.to_param,
          list_position10.to_param,
          list_position11.to_param,
          list_position12.to_param,
        )

        # Subbing in a substitute defender
        api.get(api_list_position_url(list_position15.id))
        # All starting outfielders can be subbed out except for the starting forward since there is only one
        expect(api.data['valid_substitutions']).to contain_exactly(
          list_position2.to_param,
          list_position3.to_param,
          list_position4.to_param,
          list_position5.to_param,
          list_position6.to_param,
          list_position9.to_param,
          list_position10.to_param,
          list_position11.to_param,
          list_position12.to_param,
        )
      end
    end

    context '3 forwards, 2 midfielders, 5 defenders' do
      let!(:list_position9) { create :list_position, :starting, :forward, fpl_team_list_id: fpl_team_list.id }
      let!(:list_position10) { create :list_position, :starting, :forward, fpl_team_list_id: fpl_team_list.id }
      let!(:list_position11) { create :list_position, :starting, :defender, fpl_team_list_id: fpl_team_list.id }
      let!(:list_position12) { create :list_position, :starting, :defender, fpl_team_list_id: fpl_team_list.id }
      let!(:list_position13) { create :list_position, :substitute_1, :midfielder, fpl_team_list_id: fpl_team_list.id }
      let!(:list_position14) { create :list_position, :substitute_2, :midfielder, fpl_team_list_id: fpl_team_list.id }
      let!(:list_position15) { create :list_position, :substitute_3, :midfielder, fpl_team_list_id: fpl_team_list.id }

      it 'shows valid potential substitutions' do
        # Subbing out a starting forward
        api.get(api_list_position_url(list_position1.id))
        # All substitutes can be subbed in
        expect(api.data['valid_substitutions']).to contain_exactly(
          list_position13.to_param,
          list_position14.to_param,
          list_position15.to_param,
        )

        # Subbing out the starting goalkeeper
        api.get(api_list_position_url(list_position7.id))
        # Can only sub in the substitute goalkeeper
        expect(api.data['valid_substitutions']).to contain_exactly(
          list_position8.to_param,
        )

        # Subbing in a the substitute goalkeeper
        api.get(api_list_position_url(list_position8.id))
        # Can only sub out the starting goalkeeper
        expect(api.data['valid_substitutions']).to contain_exactly(
          list_position7.to_param,
        )

        # Subbing out a starting forward
        api.get(api_list_position_url(list_position13.id))
        # All starting outfielders can be subbed out
        expect(api.data['valid_substitutions']).to contain_exactly(
          list_position1.to_param,
          list_position2.to_param,
          list_position3.to_param,
          list_position4.to_param,
          list_position5.to_param,
          list_position6.to_param,
          list_position9.to_param,
          list_position10.to_param,
          list_position11.to_param,
          list_position12.to_param,
        )
      end
    end
  end
end
