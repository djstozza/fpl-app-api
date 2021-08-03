# Base serializer from which all other serializers are derived
class BaseSerializer < SimpleDelegator
  attr_reader :object, :includes

  def self.map(collection, *args)
    collection.map { |e| new(e, *args) }
  end

  def initialize(object, **includes)
    super(object)
    @object = object
    @includes = includes
  end

  def as_json(*args)
    object ? stringify_ids(serializable_hash(*args)) : nil
  end

  private

  # BIGINT can be transferred incorrectly to the front-end so it's best to send it across as a string
  def stringify_ids(serialized_hash)
    serialized_hash.each do |key, value|
      serialized_hash[key] = value.to_s.presence if /^id$|.*_id$/.match?(key.to_s)
    end
  end
end
