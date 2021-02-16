# == Schema Information
#
# Table name: rounds
#
#  id                        :bigint           not null, primary key
#  data_checked              :boolean
#  deadline_time             :string
#  deadline_time_epoch       :integer
#  deadline_time_game_offset :integer
#  finished                  :boolean
#  is_current                :boolean
#  is_next                   :boolean
#  is_previous               :boolean
#  name                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  external_id               :integer
#
FactoryBot.define do
  factory :round do
    sequence :name do |n|
      "Gameweek #{n}"
    end

    sequence :external_id do |n|
      n
    end

    deadline_time_game_offset { 0 }

    trait :current do
      is_current { true }
      is_next { false }
      is_previous { false }
      data_checked { false }
      finished { false }

      time = 3.days.from_now
      deadline_time { time }
      deadline_time_epoch { time.to_i }
    end

    trait :next do
      is_current { false }
      is_next { true }
      is_previous { false }
      data_checked { false }
      finished { false }

      time = 1.week.from_now
      deadline_time { time }
      deadline_time_epoch { time.to_i }
    end

    trait :previous do
      is_current { false }
      is_next { false }
      is_previous { true }
      data_checked { true }
      finished { true }

      time = 1.day.ago
      deadline_time { time }
      deadline_time_epoch { time.to_i }
    end

    trait :past do
      is_current { false }
      is_next { false }
      is_previous { false }
      data_checked { true }
      finished { true }

      time = 1.week.ago
      deadline_time { time }
      deadline_time_epoch { time.to_i }
    end

    trait :future do
      is_current { false }
      is_next { false }
      is_previous { false }
      data_checked { false }
      finished { false }

      time = 2.weeks.from_now
      deadline_time { time }
      deadline_time_epoch { time.to_i }
    end
  end
end
