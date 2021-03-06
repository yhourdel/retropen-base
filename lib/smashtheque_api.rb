require "uri"
require "net/http"

class SmashthequeApi

  BASE_URL = 'https://www.smashtheque.fr/api/v1'.freeze
  AUTH_TOKEN = ENV['SMASHTHEQUE_API_TOKEN'].freeze

  def self.players
    api_get 'players?per=500'
  end

  def self.characters
    api_get 'characters?per=1000'
  end

  def self.discord_guilds
    api_get 'discord_guilds?per=1000'
  end

  def self.communities
    api_get 'communities?per=1000'
  end

  def self.teams
    api_get 'teams?per=1000'
  end

  def self.recurring_tournaments
    api_get 'recurring_tournaments?per=1000'
  end

  def self.api_get(path)
    url = URI("#{BASE_URL}/#{path}")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Accept"] = "application/json"
    request["Authorization"] = "Bearer #{AUTH_TOKEN}"

    response = https.request(request)
    JSON.parse response.read_body
  end

end
