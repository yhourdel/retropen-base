# == Schema Information
#
# Table name: users
#
#  id                            :bigint           not null, primary key
#  admin_level                   :string
#  coaching_details              :string
#  coaching_url                  :string
#  current_sign_in_at            :datetime
#  current_sign_in_ip            :inet
#  encrypted_password            :string           default(""), not null
#  graphic_designer_details      :string
#  is_available_graphic_designer :boolean          default(FALSE), not null
#  is_caster                     :boolean          default(FALSE), not null
#  is_coach                      :boolean          default(FALSE), not null
#  is_graphic_designer           :boolean          default(FALSE), not null
#  is_root                       :boolean          default(FALSE), not null
#  last_sign_in_at               :datetime
#  last_sign_in_ip               :inet
#  name                          :string           not null
#  sign_in_count                 :integer          default(0), not null
#  twitter_username              :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
class User < ApplicationRecord

  # ---------------------------------------------------------------------------
  # MODULES
  # ---------------------------------------------------------------------------

  devise :database_authenticatable
  devise :trackable
  devise :omniauthable, omniauth_providers: %i[discord]

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_one :discord_user, dependent: :nullify
  has_one :player, dependent: :nullify

  has_many :created_players,
           class_name: :Player,
           foreign_key: :creator_user_id

  has_many :recurring_tournament_contacts,
           inverse_of: :user,
           dependent: :destroy
  has_many :administrated_recurring_tournaments,
           through: :recurring_tournament_contacts,
           source: :recurring_tournament

  has_many :team_admins,
           inverse_of: :user,
           dependent: :destroy
  has_many :administrated_teams,
           through: :team_admins,
           source: :team

  accepts_nested_attributes_for :player

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :name, presence: true
  validates :admin_level,
            inclusion: {
              in: Ability::ADMIN_LEVELS,
              allow_nil: true
            }

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] }
  def update_discord
    # on create: previous_changes = {"id"=>[nil, <id>], "name"=>[nil, <name>], ...}
    # on update: previous_changes = {"name"=>["old_name", "new_name"], ...}
    # on delete: destroyed? = true and old attributes are available

    if destroyed?
      RetropenBotScheduler.rebuild_casters_list if is_caster?
      RetropenBotScheduler.rebuild_coaches_list if is_coach?
      RetropenBotScheduler.rebuild_graphic_designers_list if is_graphic_designer?
    else
      if is_caster? || previous_changes.has_key?('is_caster')
        RetropenBotScheduler.rebuild_casters_list
      end
      if is_coach? || previous_changes.has_key?('is_coach')
        RetropenBotScheduler.rebuild_coaches_list
      end
      if is_graphic_designer? || previous_changes.has_key?('is_graphic_designer')
        RetropenBotScheduler.rebuild_graphic_designers_list
      end
    end
  end

  def twitter_username=(v)
    super (v || '').gsub('https://', '')
                   .gsub('http://', '')
                   .gsub('twitter.com/', '')
                   .gsub('@', '')
                   .strip
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  include PgSearch::Model
  pg_search_scope :by_pg_search,
                  against: [:name],
                  using: {
                    tsearch: { prefix: true }
                  }

  def self.not_root
    where(is_root: false)
  end

  def self.lambda
    not_root.where(admin_level: nil)
  end

  def self.helps
    not_root.where(admin_level: Ability::ADMIN_LEVEL_HELP)
  end

  def self.admins
    not_root.where(admin_level: Ability::ADMIN_LEVEL_ADMIN)
  end

  def self.roots
    where(is_root: true)
  end

  def self.without_discord_user
    where.not(
      id: DiscordUser.where.not(user_id: nil).select(:user_id)
    )
  end

  def self.without_player
    where.not(
      id: Player.where.not(user_id: nil).select(:user_id)
    )
  end

  def self.without_created_player
    where.not(
      id: Player.where.not(creator_user_id: nil).select(:creator_user_id)
    )
  end

  def self.without_administrated_recurring_tournament
    where.not(
      id: RecurringTournamentContact.where.not(user_id: nil).select(:user_id)
    )
  end

  def self.without_administrated_team
    where.not(
      id: TeamAdmin.where.not(user_id: nil).select(:user_id)
    )
  end

  def self.without_any_link
    self.without_discord_user
        .without_player
        .without_created_player
        .without_administrated_recurring_tournament
        .without_administrated_team
  end

  def self.recurring_tournament_contacts
    where(id: RecurringTournamentContact.select(:user_id))
  end

  def self.team_admins
    where(id: TeamAdmin.select(:user_id))
  end

  def self.casters
    where(is_caster: true)
  end

  def self.coaches
    where(is_coach: true)
  end

  def self.graphic_designers
    where(is_graphic_designer: true)
  end

  def self.on_abc(letter)
    where("unaccent(name) ILIKE '#{letter}%'")
  end

  def self.by_name(name)
    where(name: name)
  end

  def self.by_name_like(name)
    where('unaccent(name) ILIKE unaccent(?)', name)
  end

  def self.by_name_contains_like(term)
    where("unaccent(name) ILIKE unaccent(?)", "%#{term}%")
  end

  def self.by_keyword(term)
    by_name_contains_like(term).or(
      where(id: by_pg_search(term).select(:id))
    )
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def self.from_discord_omniauth(auth)
    puts "User#from_omniauth(#{auth.inspect})"

    # make sure auth comes from Discord
    return false unless auth.provider.to_sym == :discord

    # find & update DiscordUser
    discord_user = DiscordUser.where(discord_id: auth.uid).first_or_initialize
    discord_user.attributes = {
      username: auth.extra.raw_info.username,
      discriminator: auth.extra.raw_info.discriminator,
      avatar: auth.extra.raw_info.avatar
    }
    discord_user.save!

    # find & return User
    discord_user.return_or_create_user!
  end

  def admin_level=(v)
    super v.presence
  end

  def is_admin?
    !admin_level.nil?
  end

  # provides: @discord_user_id
  delegate :id,
           to: :discord_user,
           prefix: true,
           allow_nil: true

  # provides: @discord_id
  delegate :discord_id,
           to: :discord_user,
           allow_nil: true

  # provides: @discord_user_username
  delegate :username,
           to: :discord_user,
           prefix: true

  def potential_discord_user
    return nil unless discord_user.nil?
    DiscordUser.without_user.by_username_like(name).first
  end

  def _potential_discord_user
    @potential_discord_user ||= potential_discord_user
  end

end
