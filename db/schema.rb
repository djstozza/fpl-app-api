# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_02_10_060327) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "draft_picks", force: :cascade do |t|
    t.integer "pick_number"
    t.boolean "mini_draft", default: false, null: false
    t.bigint "fpl_team_id"
    t.bigint "player_id"
    t.bigint "league_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fpl_team_id"], name: "index_draft_picks_on_fpl_team_id"
    t.index ["league_id"], name: "index_draft_picks_on_league_id"
    t.index ["pick_number", "league_id"], name: "index_draft_picks_on_pick_number_and_league_id", unique: true
    t.index ["player_id", "league_id"], name: "index_draft_picks_on_player_id_and_league_id", unique: true
    t.index ["player_id"], name: "index_draft_picks_on_player_id"
  end

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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_fixtures_on_external_id", unique: true
    t.index ["round_id"], name: "index_fixtures_on_round_id"
    t.index ["team_a_id"], name: "index_fixtures_on_team_a_id"
    t.index ["team_h_id"], name: "index_fixtures_on_team_h_id"
  end

  create_table "fpl_team_lists", force: :cascade do |t|
    t.integer "round_rank"
    t.integer "cumulative_rank"
    t.integer "total_score"
    t.bigint "fpl_team_id"
    t.bigint "round_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fpl_team_id", "round_id"], name: "index_fpl_team_lists_on_fpl_team_id_and_round_id", unique: true
    t.index ["fpl_team_id"], name: "index_fpl_team_lists_on_fpl_team_id"
    t.index ["round_id"], name: "index_fpl_team_lists_on_round_id"
  end

  create_table "fpl_teams", force: :cascade do |t|
    t.citext "name", null: false
    t.integer "draft_pick_number"
    t.integer "mini_draft_pick_number"
    t.integer "rank"
    t.bigint "owner_id"
    t.bigint "league_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["draft_pick_number", "league_id"], name: "index_fpl_teams_on_draft_pick_number_and_league_id", unique: true
    t.index ["league_id"], name: "index_fpl_teams_on_league_id"
    t.index ["mini_draft_pick_number", "league_id"], name: "index_fpl_teams_on_mini_draft_pick_number_and_league_id", unique: true
    t.index ["name"], name: "index_fpl_teams_on_name", unique: true
    t.index ["owner_id"], name: "index_fpl_teams_on_owner_id"
  end

  create_table "fpl_teams_players", id: false, force: :cascade do |t|
    t.bigint "fpl_team_id", null: false
    t.bigint "player_id", null: false
    t.index ["fpl_team_id"], name: "index_fpl_teams_players_on_fpl_team_id"
    t.index ["player_id"], name: "index_fpl_teams_players_on_player_id"
  end

  create_table "inter_team_trade_groups", force: :cascade do |t|
    t.bigint "out_fpl_team_list_id"
    t.bigint "in_fpl_team_list_id"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["in_fpl_team_list_id"], name: "index_inter_team_trade_groups_on_in_fpl_team_list_id"
    t.index ["out_fpl_team_list_id"], name: "index_inter_team_trade_groups_on_out_fpl_team_list_id"
  end

  create_table "inter_team_trades", force: :cascade do |t|
    t.bigint "inter_team_trade_group_id"
    t.bigint "out_player_id"
    t.bigint "in_player_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["in_player_id", "inter_team_trade_group_id"], name: "unique_in_player", unique: true
    t.index ["in_player_id"], name: "index_inter_team_trades_on_in_player_id"
    t.index ["inter_team_trade_group_id"], name: "index_inter_team_trades_on_inter_team_trade_group_id"
    t.index ["out_player_id", "inter_team_trade_group_id"], name: "unique_out_player", unique: true
    t.index ["out_player_id"], name: "index_inter_team_trades_on_out_player_id"
  end

  create_table "leagues", force: :cascade do |t|
    t.citext "name", null: false
    t.string "code", null: false
    t.integer "status", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.bigint "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "fpl_teams_count", default: 0, null: false
    t.index ["name"], name: "index_leagues_on_name", unique: true
    t.index ["owner_id"], name: "index_leagues_on_owner_id"
  end

  create_table "list_positions", force: :cascade do |t|
    t.integer "role", null: false
    t.bigint "fpl_team_list_id"
    t.bigint "player_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fpl_team_list_id"], name: "index_list_positions_on_fpl_team_list_id"
    t.index ["player_id", "fpl_team_list_id"], name: "index_list_positions_on_player_id_and_fpl_team_list_id", unique: true
    t.index ["player_id"], name: "index_list_positions_on_player_id"
  end

  create_table "mini_draft_picks", force: :cascade do |t|
    t.integer "pick_number"
    t.integer "season", null: false
    t.boolean "passed", default: false, null: false
    t.bigint "out_player_id"
    t.bigint "in_player_id"
    t.bigint "fpl_team_id"
    t.bigint "league_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fpl_team_id"], name: "index_mini_draft_picks_on_fpl_team_id"
    t.index ["in_player_id"], name: "index_mini_draft_picks_on_in_player_id"
    t.index ["league_id"], name: "index_mini_draft_picks_on_league_id"
    t.index ["out_player_id"], name: "index_mini_draft_picks_on_out_player_id"
    t.index ["pick_number", "league_id", "season"], name: "index_mini_draft_picks_on_pick_number_and_league_id_and_season", unique: true
  end

  create_table "players", force: :cascade do |t|
    t.integer "chance_of_playing_next_round"
    t.integer "chance_of_playing_this_round"
    t.integer "code"
    t.integer "dreamteam_count"
    t.integer "event_points"
    t.citext "first_name"
    t.citext "last_name"
    t.decimal "form"
    t.integer "external_id"
    t.boolean "in_dreamteam"
    t.string "news"
    t.datetime "news_added", precision: nil
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "history"
    t.jsonb "history_past"
    t.index ["external_id"], name: "index_players_on_external_id", unique: true
    t.index ["id", "first_name"], name: "index_players_on_id_and_first_name"
    t.index ["id", "goals_scored"], name: "index_players_on_id_and_goals_scored"
    t.index ["id", "last_name"], name: "index_players_on_id_and_last_name"
    t.index ["id", "total_points"], name: "index_players_on_id_and_total_points"
    t.index ["position_id"], name: "index_players_on_position_id"
    t.index ["team_id"], name: "index_players_on_team_id"
  end

  create_table "positions", force: :cascade do |t|
    t.citext "singular_name"
    t.citext "singular_name_short"
    t.citext "plural_name"
    t.citext "plural_name_short"
    t.integer "squad_select"
    t.integer "squad_min_play"
    t.integer "squad_max_play"
    t.integer "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_positions_on_external_id", unique: true
  end

  create_table "rounds", force: :cascade do |t|
    t.citext "name"
    t.string "deadline_time"
    t.boolean "finished"
    t.boolean "data_checked"
    t.integer "deadline_time_epoch"
    t.integer "deadline_time_game_offset"
    t.boolean "is_previous"
    t.boolean "is_current"
    t.boolean "is_next"
    t.integer "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "mini_draft", default: false, null: false
    t.index ["external_id"], name: "index_rounds_on_external_id", unique: true
  end

  create_table "teams", force: :cascade do |t|
    t.integer "external_id"
    t.citext "name"
    t.integer "code"
    t.citext "short_name"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_teams_on_external_id", unique: true
  end

  create_table "trades", force: :cascade do |t|
    t.bigint "out_player_id"
    t.bigint "in_player_id"
    t.bigint "fpl_team_list_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fpl_team_list_id"], name: "index_trades_on_fpl_team_list_id"
    t.index ["in_player_id"], name: "index_trades_on_in_player_id"
    t.index ["out_player_id"], name: "index_trades_on_out_player_id"
  end

  create_table "users", force: :cascade do |t|
    t.citext "email", default: "", null: false
    t.citext "username", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "waiver_picks", force: :cascade do |t|
    t.integer "pick_number", null: false
    t.integer "status", default: 0, null: false
    t.bigint "out_player_id"
    t.bigint "in_player_id"
    t.bigint "fpl_team_list_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fpl_team_list_id"], name: "index_waiver_picks_on_fpl_team_list_id"
    t.index ["in_player_id"], name: "index_waiver_picks_on_in_player_id"
    t.index ["out_player_id"], name: "index_waiver_picks_on_out_player_id"
    t.index ["pick_number", "fpl_team_list_id"], name: "index_waiver_picks_on_pick_number_and_fpl_team_list_id", unique: true
  end

  add_foreign_key "inter_team_trade_groups", "fpl_team_lists", column: "in_fpl_team_list_id"
  add_foreign_key "inter_team_trade_groups", "fpl_team_lists", column: "out_fpl_team_list_id"
  add_foreign_key "inter_team_trades", "players", column: "in_player_id"
  add_foreign_key "inter_team_trades", "players", column: "out_player_id"
  add_foreign_key "mini_draft_picks", "players", column: "in_player_id"
  add_foreign_key "mini_draft_picks", "players", column: "out_player_id"
  add_foreign_key "trades", "players", column: "in_player_id"
  add_foreign_key "trades", "players", column: "out_player_id"
  add_foreign_key "waiver_picks", "players", column: "in_player_id"
  add_foreign_key "waiver_picks", "players", column: "out_player_id"
end
