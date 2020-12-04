# == Schema Information
#
# Table name: discord_guilds
#
#  id               :bigint           not null, primary key
#  icon             :string
#  invitation_url   :string
#  name             :string
#  old_related_type :string
#  splash           :string
#  twitter_username :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  discord_id       :string
#  old_related_id   :bigint
#
# Indexes
#
#  index_discord_guilds_on_old_related_type_and_old_related_id  (old_related_type,old_related_id)
#
class DiscordGuild < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_many :discord_guild_admins,
           inverse_of: :discord_guild,
           dependent: :destroy
  has_many :admins,
           through: :discord_guild_admins,
           source: :discord_user

  has_many :discord_guild_relateds,
           inverse_of: :discord_guild,
           dependent: :destroy
  # has_many :relateds,
  #          through: :discord_guild_relateds,
  #          source: :related,
  #          foreign_type: :related_type
  def relateds
    discord_guild_relateds.map(&:related)
  end

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :discord_id,
            uniqueness: {
              allow_blank: true
            }

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_create_commit :fetch_discord_data_later
  def fetch_discord_data_later
    FetchDiscordGuildDataJob.perform_later(self)
  end

  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] }
  def update_discord
    RetropenBotScheduler.rebuild_discord_guilds_chars_list
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.known
    where.not(icon: nil)
  end

  def self.unknown
    where(icon: nil)
  end

  def self.by_related_type(v)
    where(id: DiscordGuildRelated.by_related_type(v).select(:discord_guild_id))
  end

  def self.by_related_id(v)
    where(id: DiscordGuildRelated.by_related_id(v).select(:discord_guild_id))
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def related_gids
    self.discord_guild_relateds.map(&:related_gid)
  end

  def related_gids=(gids)
    self.discord_guild_relateds = gids.map(&:presence).compact.map do |gid|
      self.discord_guild_relateds.build(related_gid: gid)
    end
  end

  def fetch_discord_data
    client = DiscordClient.new
    if discord_id.blank?
      unless invitation_url.blank?
        data = client.get_guild_from_invitation(invitation_url)
        if data.has_key?('guild') && data['guild'].has_key?('name')
          self.attributes = {
            discord_id: data['guild']['id'],
            name: data['guild']['name'],
            icon: data['guild']['icon'],
            splash: data['guild']['splash']
          }
        end
      end
    else
      data = client.get_guild discord_id
      if data.has_key?('name')
        self.attributes = {
          name: data['name'],
          icon: data['icon'],
          splash: data['splash']
        }
      end
    end
  end

  def self.fetch_unknown
    unknown.find_each do |discord_guild|
      discord_guild.fetch_discord_data
      discord_guild.save!
      # we need to wait a bit between each request,
      # otherwise Discord return empty results
      sleep 1
    end
  end

  def is_known?
    !!icon
  end

end
