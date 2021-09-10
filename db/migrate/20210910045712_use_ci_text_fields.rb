class UseCiTextFields < ActiveRecord::Migration[6.0]
  def up
    enable_extension 'citext'
    change_column :players, :last_name, :citext
    change_column :players, :first_name, :citext
    change_column :users, :username, :citext
    change_column :users, :email,:citext
    change_column :leagues, :name, :citext
    change_column :fpl_teams, :name, :citext
    change_column :teams, :name, :citext
    change_column :teams, :short_name, :citext
    change_column :positions, :singular_name_short, :citext
    change_column :positions, :singular_name, :citext
    change_column :positions, :plural_name_short, :citext
    change_column :positions, :plural_name, :citext
    change_column :rounds, :name, :citext
  end

  def down
    change_column :players, :last_name, :string
    change_column :players, :first_name, :string
    change_column :users, :username, :string
    change_column :users, :email,:string
    change_column :leagues, :name, :string
    change_column :fpl_teams, :name, :string
    change_column :teams, :name, :string
    change_column :teams, :short_name, :citext
    change_column :positions, :singular_name_short, :string
    change_column :positions, :singular_name, :string
    change_column :positions, :plural_name_short, :string
    change_column :positions, :plural_name, :string
    change_column :rounds, :name, :string
  end
end
