# == Schema Information
#
# Table name: leagues
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(TRUE), not null
#  code            :string           not null
#  fpl_teams_count :integer          default(0), not null
#  name            :citext           not null
#  status          :integer          default("initialized"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  owner_id        :bigint
#
# Indexes
#
#  index_leagues_on_name      (name) UNIQUE
#  index_leagues_on_owner_id  (owner_id)
#
FactoryBot.define do
  factory :league do
    sequence :name do |n|
      "League #{n}"
    end

    trait 'live' do
      status { 'live' }
    end

    code { '12345678' }

    association :owner, factory: :user
  end
end
