module ErrorSerialization
  def serialized_errors(resource)
    { errors: ActiveModelErrorsSerializer.new(resource.errors) }
  end
end
