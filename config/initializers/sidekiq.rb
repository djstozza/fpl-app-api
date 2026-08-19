require 'sidekiq/throttled'

# Heroku Redis uses a self-signed cert on its rediss:// endpoints; newer
# redis-client versions default to strict TLS verification, which rejects it.
if ENV['REDIS_URL']&.start_with?('rediss://')
  redis_config = { url: ENV['REDIS_URL'], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }

  Sidekiq.configure_server { |config| config.redis = redis_config }
  Sidekiq.configure_client { |config| config.redis = redis_config }
end
