module APIHelpers
  class TestClient
    ENV['CORS_ALLOWED_ORIGINS'] = 'example.com'

    delegate :response, to: :session

    attr_reader :session
    attr_accessor :application, :user, :auth

    def initialize(session)
      @session = session
      @results = Hash.new { |hash, key| hash[key] = {} }
    end

    def authenticate(user)
      token = Users::BaseService.call({}, user: user).token

      headers['Authorization'] = "Bearer #{token}"
    end

    def deuthenticate
      headers.delete('Authorization')
    end

    def headers
      @headers ||= {
        'Origin' => 'https://example.com',
      }
    end

    %i[get post put delete].each do |http_method|
      define_method(http_method) { |*args| process(http_method, *args) }
    end

    def process(method, path, headers: {}, **args)
      if (json = args.delete(:json))
        headers['Content-Type'] = 'application/json'
        args[:params] = json.to_json
      end

      session.process(
        method,
        path,
        headers: self.headers.merge(headers),
        **args
      )
    end

    def json
      fetch_result(:json) { JSON.parse(response.body) }
    end

    def data
      fetch_result(:data) { json.dig('data') }
    end

    def errors
      fetch_result(:errors) { json.dig('errors') }
    end

    def meta
      fetch_result(:errors) { json.dig('meta') }
    end

    def timestamp(*attrs)
      Time.zone.parse(data.dig(*attrs))
    end

    private

    def fetch_result(key)
      @results[response][key] ||= yield
    end
  end
end
