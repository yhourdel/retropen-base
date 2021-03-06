class LinkTeamsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :team_admins, :user_id, :integer
    add_index :team_admins, :user_id
    add_foreign_key :team_admins, :users, column: :user_id
    TeamAdmin.find_each do |team_admin|
      next if team_admin['discord_user_id'].nil?
      TeamAdmin.where(id: team_admin.id)
               .update_all(
                 user_id: DiscordUser.find(team_admin['discord_user_id'])
                                     .return_or_create_user!
                                     .id
               )
    end
    remove_column :team_admins, :discord_user_id
  end
end
