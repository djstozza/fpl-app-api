# == Schema Information
#
# Table name: teams
#
#  id                    :bigint           not null, primary key
#  clean_sheets          :integer
#  code                  :integer
#  draws                 :integer
#  form                  :jsonb
#  goal_difference       :integer
#  goals_against         :integer
#  goals_for             :integer
#  losses                :integer
#  name                  :string
#  played                :integer
#  points                :integer
#  position              :integer
#  short_name            :string
#  strength              :integer
#  strength_attack_away  :integer
#  strength_attack_home  :integer
#  strength_defence_away :integer
#  strength_defence_home :integer
#  strength_overall_away :integer
#  strength_overall_home :integer
#  wins                  :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  external_id           :integer
#
# Indexes
#
#  index_teams_on_external_id  (external_id) UNIQUE
#
FactoryBot.define do
  factory :team do
    sequence :external_id do |n|
      n
    end

    sequence :code do |n|
      n
    end

    sequence :name do |n|
      "Team Name #{n}"
    end

    sequence :short_name do |n|
      "TN#{n}"
    end

    form { %w[W W L D W] }
  end
end
