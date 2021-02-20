# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_02_17_114349) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "fixtures", force: :cascade do |t|
    t.string "kickoff_time"
    t.integer "team_h_difficulty"
    t.integer "team_a_difficulty"
    t.integer "code"
    t.integer "team_h_score"
    t.integer "team_a_score"
    t.integer "minutes"
    t.boolean "started"
    t.boolean "finished"
    t.boolean "provisional_start_time"
    t.boolean "finished_provisional"
    t.jsonb "stats"
    t.bigint "round_id"
    t.bigint "team_h_id"
    t.bigint "team_a_id"
    t.integer "external_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["round_id"], name: "index_fixtures_on_round_id"
    t.index ["team_a_id"], name: "index_fixtures_on_team_a_id"
    t.index ["team_h_id"], name: "index_fixtures_on_team_h_id"
  end

  create_table "players", force: :cascade do |t|
    t.integer "chance_of_playing_next_round"
    t.integer "chance_of_playing_this_round"
    t.integer "code"
    t.integer "dreamteam_count"
    t.integer "event_points"
    t.string "first_name"
    t.string "last_name"
    t.decimal "form"
    t.integer "external_id"
    t.boolean "in_dreamteam"
    t.string "news"
    t.datetime "news_added"
    t.string "photo"
    t.decimal "points_per_game"
    t.decimal "selected_by_percent"
    t.boolean "special"
    t.string "status"
    t.integer "total_points"
    t.integer "minutes"
    t.integer "goals_scored"
    t.integer "assists"
    t.integer "clean_sheets"
    t.integer "goals_conceded"
    t.integer "own_goals"
    t.integer "penalties_saved"
    t.integer "penalties_missed"
    t.integer "yellow_cards"
    t.integer "red_cards"
    t.integer "saves"
    t.integer "bonus"
    t.integer "bps"
    t.decimal "creativity"
    t.decimal "influence"
    t.decimal "ict_index"
    t.decimal "threat"
    t.bigint "position_id"
    t.bigint "team_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["position_id"], name: "index_players_on_position_id"
    t.index ["team_id"], name: "index_players_on_team_id"
  end

  create_table "positions", force: :cascade do |t|
    t.string "singular_name"
    t.string "singular_name_short"
    t.string "plural_name"
    t.string "plural_name_short"
    t.integer "squad_select"
    t.integer "squad_min_play"
    t.integer "squad_max_play"
    t.integer "external_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "rounds", force: :cascade do |t|
    t.string "name"
    t.string "deadline_time"
    t.boolean "finished"
    t.boolean "data_checked"
    t.integer "deadline_time_epoch"
    t.integer "deadline_time_game_offset"
    t.boolean "is_previous"
    t.boolean "is_current"
    t.boolean "is_next"
    t.integer "external_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "teams", force: :cascade do |t|
    t.integer "external_id"
    t.string "name"
    t.integer "code"
    t.string "short_name"
    t.integer "strength"
    t.integer "position"
    t.integer "played"
    t.integer "wins"
    t.integer "losses"
    t.integer "draws"
    t.integer "clean_sheets"
    t.integer "goals_for"
    t.integer "goals_against"
    t.integer "goal_difference"
    t.integer "points"
    t.jsonb "form"
    t.integer "strength_overall_home"
    t.integer "strength_overall_away"
    t.integer "strength_attack_home"
    t.integer "strength_attack_away"
    t.integer "strength_defence_home"
    t.integer "strength_defence_away"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
