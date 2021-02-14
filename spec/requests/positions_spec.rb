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

RSpec.describe "/api/positions", type: :request do
  describe "GET /index" do
    let!(:position1) { create :position, :forward }
    let!(:position2) { create :position, :defender }

    it "renders a successful response" do
      api.get api_positions_url

      expect(response).to be_successful

      expect(api.data).to contain_exactly(
        {
          'id' => position1.to_param,
          'plural_name' => position1.plural_name,
          'plural_name_short' => position1.plural_name_short,
          'singular_name' => position1.singular_name,
          'singular_name_short' => position1.singular_name_short,
          'squad_select' => position1.squad_select,
          'squad_min_play' => position1.squad_min_play,
          'squad_max_play' => position1.squad_max_play,
        },
        {
          'id' => position2.to_param,
          'plural_name' => position2.plural_name,
          'plural_name_short' => position2.plural_name_short,
          'singular_name' => position2.singular_name,
          'singular_name_short' => position2.singular_name_short,
          'squad_select' => position2.squad_select,
          'squad_min_play' => position2.squad_min_play,
          'squad_max_play' => position2.squad_max_play,
        },
      )
    end
  end
end
