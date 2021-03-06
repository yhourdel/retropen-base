module HasTrackRecordsDecorator
  def points_count(icon_size = 32, options = {})
    options[:height] = icon_size
    is_online = options.delete(:is_online)
    year = options.delete(:year)
    value = options.delete(:value) || points(is_online: is_online, year: year)
    emoji = is_online ? RetropenBot::EMOJI_POINTS_ONLINE : RetropenBot::EMOJI_POINTS_OFFLINE
    [
      h.image_tag(
        "https://cdn.discordapp.com/emojis/#{emoji}.png",
        options
      ),
      h.number_with_delimiter(value)
    ].join('&nbsp;').html_safe
  end

  def best_rewards_badges(opt = {})
    options = opt.clone
    best_reward_conditions(
      is_online: options.delete(:is_online)
    ).map do |reward_condition|
      reward_condition.decorate.reward_badge(options)
    end
  end

  def unique_rewards_badges(opt = {})
    options = opt.clone
    unique_reward_conditions(
      is_online: options.delete(:is_online)
    ).map do |reward_condition|
      reward_condition.decorate.reward_badge(options)
    end
  end
end
