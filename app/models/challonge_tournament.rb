# == Schema Information
#
# Table name: challonge_tournaments
#
#  id                     :bigint           not null, primary key
#  name                   :string
#  participants_count     :integer
#  slug                   :string           not null
#  start_at               :datetime
#  top1_participant_name  :string
#  top2_participant_name  :string
#  top3_participant_name  :string
#  top4_participant_name  :string
#  top5a_participant_name :string
#  top5b_participant_name :string
#  top7a_participant_name :string
#  top7b_participant_name :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  challonge_id           :integer          not null
#
# Indexes
#
#  index_challonge_tournaments_on_challonge_id  (challonge_id) UNIQUE
#  index_challonge_tournaments_on_slug          (slug) UNIQUE
#
class ChallongeTournament < ApplicationRecord

  PARTICIPANT_NAMES = TournamentEvent::PLAYER_RANKS.map do |rank|
    "top#{rank}_participant_name".to_sym
  end.freeze

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_one :tournament_event, dependent: :nullify

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :challonge_id, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.with_tournament_event
    where(id: TournamentEvent.select(:challonge_tournament_id))
  end
  def self.without_tournament_event
    where.not(id: TournamentEvent.select(:challonge_tournament_id))
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def self.slug_from_url(url)
    url.gsub(/https:\/\/challonge.com\//, '').gsub(/(fr|en)\//, '')
  end

  def challonge_url=(url)
    self.slug = self.class.slug_from_url(url)
  end

  def self.from_slug(slug)
    o = where(slug: slug).first_or_initialize
    o.fetch_challonge_data
    o
  end

  def self.from_url(url)
    if slug = slug_from_url(url)
      from_slug(slug)
    else
      nil
    end
  end

  def self.attributes_from_api_data(data)
    result = {
      challonge_id: data['id'],
      slug: data['url'],

      name: data['name'],
      start_at: DateTime.parse(data['start_at']),
      participants_count: data['participants_count']
    }
    data['participants'].each do |_participant|
      if participant = _participant['participant']
        placement = participant['final_rank']
        if placement < 8
          idx = case placement
          when 5
            result.has_key?(:top5a_participant_name) ? '5b' : '5a'
          when 7
            result.has_key?(:top7a_participant_name) ? '7b' : '7a'
          else
            placement.to_s
          end
          result["top#{idx}_participant_name".to_sym] = participant['name']
        end
      end
    end
    result
  end

  def fetch_challonge_data
    api_data = ChallongeClient.new.get_tournament(slug: slug)
    self.attributes = self.class.attributes_from_api_data(api_data)
  end

  def challonge_url
    slug && "https://challonge.com/#{slug}"
  end

  def self.lookup(name:, from:, to:)
    data = ChallongeClient.new.get_tournaments(name: name, from: from, to: to)
    return nil if data.nil?
    data.map do |api_data|
      attributes = attributes_from_api_data(api_data)
      self.where(challonge_id: attributes[:challonge_id]).first_or_initialize(attributes)
    end
  end

end
