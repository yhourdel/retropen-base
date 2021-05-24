class PlayersController < PublicController
  decorates_assigned :player

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc

  layout :select_layout

  def index
    @players = players Player
    @meta_title = 'Joueurs'
  end

  def community_index
    @community = Community.find(params[:id]).decorate
    @players = players @community.model.players
    @meta_title = @community.name
    @meta_properties['og:type'] = 'profile'
    @meta_properties['og:image'] = @community.decorate.any_image_url
    render 'communities/show'
  end

  def team_index
    @team = Team.find(params[:id]).decorate
    @players = players @team.model.players
    @meta_title = @team.name
    @meta_properties['og:type'] = 'profile'
    @meta_properties['og:image'] = @team.any_image_url
    render 'teams/show'
  end

  def character_index
    @character = Character.find(params[:id]).decorate
    @players = players @character.model.players
    @background_color = @character.background_color
    @background_image_url = @character.background_image_data_url
    @background_size = @character.background_size || 128
    @meta_title = @character.pretty_name
    @meta_properties['og:type'] = 'profile'
    @meta_properties['og:image'] = @character.emoji_image_url
    render 'characters/show'
  end

  def recurring_tournament_contacts_index
    @players = players Player.recurring_tournament_contacts
    @meta_title = 'TOs'
    render 'recurring_tournaments/contacts'
  end

  def show
    @player = Player.legit.find(params[:id])
    @rewards_counts = @player.rewards_counts
    @tournament_events = @player.tournament_events
                                .order(date: :desc)
                                .includes(
                                  recurring_tournament: :discord_guild
                                ).decorate
    @met_reward_conditions_by_tournament_event_id = Hash[
      @player.met_reward_conditions
             .includes(
               reward: {
                 image_attachment: :blob
               }
             ).map do |met_reward_condition|
        [met_reward_condition.event_id, met_reward_condition]
      end
    ]
    @all_rewards = Reward.online_1v1.includes(image_attachment: :blob)
    main_character = @player.characters.first&.decorate
    if main_character
      @background_color = main_character.background_color
      @background_image_url = main_character.background_image_data_url
      @background_size = main_character.background_size || 128
    end
    @meta_title = @player.name
    @meta_properties['og:type'] = 'profile'
    @meta_properties['og:image'] = @player.decorate.any_image_url
  end

  def ranking_online
    @players = apply_scopes(
      Player.ranked.order(:rank)
    ).includes(:user, :discord_user, :teams, :characters)

    main_character = @players.first.characters.first&.decorate
    if main_character
      @background_color = main_character.background_color
      @background_image_url = main_character.background_image_data_url
      @background_size = main_character.background_size || 128
    end
    @meta_title = "Observatoire d'Harmonie Online"
  end

  def ranking_online_year
    @year = params[:year].to_i
    @players = apply_scopes(
      Player.ranked_in(@year).order("rank_in_#{@year}")
    ).includes(:user, :discord_user, :teams, :characters)

    main_character = @players.first.characters.first&.decorate
    if main_character
      @background_color = main_character.background_color
      @background_image_url = main_character.background_image_data_url
      @background_size = main_character.background_size || 128
    end
    @meta_title = "Observatoire d'Harmonie Online #{@year}"
    render 'ranking_online'
  end

  def autocomplete
    render json: {
      results: Player.by_keyword(params[:term])
                     .includes(
                       :smashgg_users, :teams, :characters,
                       user: :discord_user
                     )
                     .limit(10)
                     .decorate
                     .map do |player|
        {
          id: player.id,
          type: :player,
          avatar: player.avatar_tag(32),
          html: player.as_autocomplete_result,
          text: player.name_and_old_names
        }
      end
    }
  end

  private

  def players(base)
    @map = params[:map].to_i == 1
    @map_seconds = params[:seconds].to_i == 1 if @map
    apply_scopes(
      base.legit.order(:name)
    ).includes(
      :user, :discord_user,
      :teams, :characters, :smashgg_users,
      best_reward: { image_attachment: :blob }
    )
  end

  def select_layout
    @map ? 'map' : 'application'
  end
end
