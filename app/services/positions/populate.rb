# Populate positions service
class Positions::Populate < BasePopulateService
  def call
    response.each do |position_json|
      position = Position.find_or_create_by(external_id: position_json['id'])

      position.update!(
        plural_name: position_json['plural_name'],
        plural_name_short: position_json['plural_name_short'],
        singular_name: position_json['singular_name'],
        singular_name_short: position_json['singular_name_short'],
        squad_select: position_json['squad_select'],
        squad_min_play: position_json['squad_min_play'],
        squad_max_play: position_json['squad_max_play'],
      )
    end
  end

  private

  def response
    @response ||= ::HTTParty.get(bootstrap_static_url)['element_types']
  end
end
