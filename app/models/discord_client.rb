class DiscordClient

  MESSAGE_LINE_SEPARATOR = "\n".freeze

  def initialize(token: nil)
    @token = token || ENV['DISCORD_BOT_TOKEN']
  end

  def get_guild(guild_id)
    api_get "/guilds/#{guild_id}"
  end

  def get_guild_channels(guild_id)
    @guild_channels ||= {}
    @guild_channels[guild_id] ||= api_get "/guilds/#{guild_id}/channels"
  end

  def create_guild_category(guild_id, params)
    api_post "/guilds/#{guild_id}/channels", params.merge(
      type: 4 #GUILD_CATEGORY
    )
  end

  def find_or_create_guild_category(guild_id, find_params, create_params = {})
    existing_channels = get_guild_channels(guild_id)
    found_channel = existing_channels.find do |channel|
      compare_existing channel, find_params
    end
    return found_channel if found_channel
    create_guild_category(guild_id, find_params.merge(create_params))
  end

  def create_guild_text_channel(guild_id, params)
    api_post "/guilds/#{guild_id}/channels", params.merge(
      type: 0 #GUILD_TEXT
    )
  end

  def find_or_create_guild_text_channel(guild_id, find_params, create_params = {})
    existing_channels = get_guild_channels(guild_id)
    found_channel = existing_channels.find do |channel|
      compare_existing channel, find_params
    end
    return found_channel if found_channel
    create_guild_text_channel(guild_id, find_params.merge(create_params))
  end

  def channel(channel_id)
    @channels ||= {}
    @channels[channel_id] ||= api_get "/channels/#{channel_id}"
  end

  def channel_messages(channel_id)
    api_get "/channels/#{channel_id}/messages?limit=100"
  end

  def create_channel_message(channel_id, content)
    split_messages(content).each do |message|
      bot.send_message channel_id, message
    end
  end

  def delete_channel_message(channel_id, message_id)
    api_delete "/channels/#{channel_id}/messages/#{message_id}"
  end

  def clear_channel(channel_id)
    existing_messages = channel_messages channel_id
    existing_messages.each do |message|
      delete_channel_message channel_id, message['id']
    end
  end

  private

  def api_get(path)
    puts "=== API REQUEST ==="
    url = URI("#{Discordrb::API::APIBASE}#{path}")
    puts "GET #{url}"

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Authorization"] = "Bot #{@token}"

    response = https.request(request)

    JSON.parse(response.read_body)
  end

  def api_post(path, params)
    puts "=== API REQUEST ==="
    url = URI("#{Discordrb::API::APIBASE}#{path}")
    puts "POST #{url} #{params.to_json}"

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Authorization"] = "Bot #{@token}"
    request["Content-Type"] = 'application/json'
    request.body = params.to_json

    response = https.request(request)

    JSON.parse(response.read_body)
  end

  def api_delete(path)
    puts "=== API REQUEST ==="
    url = URI("#{Discordrb::API::APIBASE}#{path}")
    puts "DELETE #{url}"

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Delete.new(url)
    request["Authorization"] = "Bot #{@token}"

    response = https.request(request)

    response.read_body
  end

  # helpers

  def compare_existing(existing, tests)
    puts "compare_existing(#{existing}, #{tests})"
    symbolized_existing = existing.symbolize_keys
    tests.each do |test_k, test_v|
      return false if symbolized_existing[test_k.to_sym] != test_v
    end
    true
  end

  def split_messages(lines)
    messages = []
    current_message = ""
    current_message_size = 0

    lines.split(MESSAGE_LINE_SEPARATOR).each do |line|
      if current_message_size + line.size < Discordrb::CHARACTER_LIMIT - 10
        # ok to be added
        current_message += MESSAGE_LINE_SEPARATOR unless current_message_size.zero?
        current_message += line
        current_message_size = current_message.size
      else
        # too long
        messages << current_message
        current_message = line
        current_message_size = current_message.size
      end
    end
    messages << current_message

    messages
  end

  def bot
    @bot ||= (
      b = Discordrb::Bot.new token: @token
      b.run true
      b
    )
  end

end
