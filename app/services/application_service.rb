class ApplicationService
  include ActiveModel::Validations

  def self.call(*args, &block)
    # ActiveRecord::Base.transaction do
      new(*args, &block).call
    # end
  end
end
