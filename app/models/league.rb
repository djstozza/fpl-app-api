# == Schema Information
#
# Table name: leagues
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE), not null
#  code       :string           not null
#  name       :string           not null
#  status     :integer          default("initialized"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  owner_id   :bigint
#
# Indexes
#
#  index_leagues_on_owner_id  (owner_id)
#
class League < ApplicationRecord
  CODE_LENGTH = 8

  belongs_to :owner, class_name: 'User', foreign_key: :owner_id
  has_many :users, through: :fpl_teams

  validates :name, presence: true, uniqueness: { case_sensitive: false, allow_nil: true }
  validates :code, presence: true, length: { is: CODE_LENGTH, allow_nil: true }

  enum status: {
    initialized: 0,
    generate_draft_picks: 1,
    create_draft: 2,
    draft: 3,
    live: 4,
  }
end
