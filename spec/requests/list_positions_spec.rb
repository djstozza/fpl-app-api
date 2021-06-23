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

RSpec.describe "/list_positions", type: :request do
  # This should return the minimal set of attributes required to create a valid
  # ListPosition. As you add validations to ListPosition, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # ListPositionsController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) {
    {}
  }


  # describe "PATCH /update" do
  #   context "with valid parameters" do
  #     let(:new_attributes) {
  #       skip("Add a hash of attributes valid for your model")
  #     }
  #
  #     it "updates the requested list_position" do
  #       list_position = ListPosition.create! valid_attributes
  #       patch list_position_url(list_position),
  #             params: { list_position: new_attributes }, headers: valid_headers, as: :json
  #       list_position.reload
  #       skip("Add assertions for updated state")
  #     end
  #
  #     it "renders a JSON response with the list_position" do
  #       list_position = ListPosition.create! valid_attributes
  #       patch list_position_url(list_position),
  #             params: { list_position: new_attributes }, headers: valid_headers, as: :json
  #       expect(response).to have_http_status(:ok)
  #       expect(response.content_type).to match(a_string_including("application/json"))
  #     end
  #   end
  #
  #   context "with invalid parameters" do
  #     it "renders a JSON response with errors for the list_position" do
  #       list_position = ListPosition.create! valid_attributes
  #       patch list_position_url(list_position),
  #             params: { list_position: invalid_attributes }, headers: valid_headers, as: :json
  #       expect(response).to have_http_status(:unprocessable_entity)
  #       expect(response.content_type).to eq("application/json")
  #     end
  #   end
  # end
end