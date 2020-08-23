class City < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_many :players

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :icon, presence: true
  validates :name, presence: true, uniqueness: true

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.on_abc(letter)
    where("unaccent(name) ILIKE '#{letter}%'")
  end

  # ---------------------------------------------------------------------------
  # GLOBAL SEARCH
  # ---------------------------------------------------------------------------

  include PgSearch::Model
  multisearchable against: %i(name)

end
