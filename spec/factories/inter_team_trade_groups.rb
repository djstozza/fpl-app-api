# == Schema Information
#
# Table name: inter_team_trade_groups
#
#  id                   :bigint           not null, primary key
#  status               :integer          default("pending"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  in_fpl_team_list_id  :bigint
#  out_fpl_team_list_id :bigint
#
# Indexes
#
#  index_inter_team_trade_groups_on_in_fpl_team_list_id   (in_fpl_team_list_id)
#  index_inter_team_trade_groups_on_out_fpl_team_list_id  (out_fpl_team_list_id)
#
# Foreign Keys
#
#  fk_rails_...  (in_fpl_team_list_id => fpl_team_lists.id)
#  fk_rails_...  (out_fpl_team_list_id => fpl_team_lists.id)
#
FactoryBot.define do
  factory :inter_team_trade_group do
    association :out_fpl_team_list, factory: :fpl_team_list
    association :in_fpl_team_list, factory: :fpl_team_list
    status { 'pending' }

    trait 'pending' do
      status { 'pending' }
    end

    trait 'approved' do
      status { 'approved' }
    end

    trait 'declined' do
      status { 'declined' }
    end

    trait 'expired' do
      status { 'expired' }
    end
  end
end
