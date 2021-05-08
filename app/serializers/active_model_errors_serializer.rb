class ActiveModelErrorsSerializer < BaseSerializer
  def as_json(*)
    object.details.map do |key, errors|
      errors.uniq.map.with_index do |error, index|
        code = error[:error]
        {
          code: error[:error],
          title: code.to_s.humanize.titleize,
          detail: object.full_messages_for(key)[index],
          source: key,
        }
      end
    end.flatten
  end
end
