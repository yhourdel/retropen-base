module ActiveAdmin
  class TeamDecorator < TeamDecorator
    include ActiveAdmin::BaseDecorator

    decorates :team

    def admin_link(options = {})
      super({ label: full_name_with_logo(max_width: 32, max_height: 32) }.merge(options))
    end

    def discord_guilds_admin_links(options = {})
      arbre do
        ul do
          discord_guilds.each do |discord_guild|
            li do
              discord_guild.admin_decorate.admin_link(options)
            end
          end
        end
      end
    end

    def players_admin_path
      admin_players_path(q: { players_teams_team_id_in: [model.id] })
    end

    def players_admin_link
      h.link_to players_count, players_admin_path
    end

    def admins_admin_links(options = {})
      model.admins.map do |user|
        user.admin_decorate.admin_link(options)
      end
    end
  end
end
