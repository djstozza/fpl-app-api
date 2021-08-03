RSpec.shared_examples 'not found' do |klass|
  it 'returns a 404 if the record is not found' do
    id = klass.titleize.constantize.last.id
    plural = klass.pluralize

    api.get "/api/#{plural}/#{id}"
    expect(api.response).to have_http_status(:success)

    api.get "/api/#{plural}/#{id + 1}"
    expect(api.response).to have_http_status(:not_found)
  end
end
