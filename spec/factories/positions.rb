# == Schema Information
#
# Table name: positions
#
#  id                  :bigint           not null, primary key
#  plural_name         :string
#  plural_name_short   :string
#  singular_name       :string
#  singular_name_short :string
#  squad_max_play      :integer
#  squad_min_play      :integer
#  squad_select        :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  external_id         :integer
#
FactoryBot.define do
  factory :position do
    sequence :external_id do |n|
      n
    end

    trait :goalkeeper do
      plural_name { 'Goalkeepers' }
      plural_name_short { 'GKP' }
      singular_name { 'Goalkeeper' }
      singular_name_short { 'GKP' }
      squad_select { 2 }
      squad_min_play { 1 }
      squad_max_play { 1 }
    end

    trait :defender do
      plural_name { 'Defenders' }
      plural_name_short { 'DEF' }
      singular_name { 'Defender' }
      singular_name_short { 'DEF' }
      squad_select { 5 }
      squad_min_play { 3 }
      squad_max_play { 5 }
    end

    trait :midfielder do
      plural_name { 'Midfielders' }
      plural_name_short { 'MID' }
      singular_name { 'Midfielder' }
      singular_name_short { 'MID' }
      squad_select { 5 }
      squad_min_play { 2 }
      squad_max_play { 5 }
    end

    trait :forward do
      plural_name { 'Forwards' }
      plural_name_short { 'FWD' }
      singular_name { 'Forward' }
      singular_name_short { 'FWD' }
      squad_select { 3 }
      squad_min_play { 1 }
      squad_max_play { 3 }
    end
  end
end
