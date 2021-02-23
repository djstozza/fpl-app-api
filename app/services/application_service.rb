class ApplicationService
  def bootstrap_static_url
    'https://fantasy.premierleague.com/api/bootstrap-static/'
  end
  def self.call(*args, &block)
    ActiveRecord::Base.transaction do
      new(*args, &block).call
    end
  end
end
