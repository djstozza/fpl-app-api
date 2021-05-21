class ApplicationService
  include ActiveModel::Validations

  def self.call(*args, &block)
    service = new(*args, &block)

    ActiveRecord::Base.transaction(joinable: false) do
      service.call
      raise ActiveRecord::Rollback if service.errors.any?
    end

    service
  end
end
