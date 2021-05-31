class TeamDecorator < BaseDecorator
  def full_name
    "#{name} (#{short_name})"
  end

  def full_name_with_logo(options)
    [
      any_image_tag(options),
      full_name
    ].join('&nbsp;').html_safe
  end

  def short_name_with_logo(options)
    [
      any_image_tag(options),
      short_name
    ].join('&nbsp;').html_safe
  end

  def autocomplete_name
    full_name
  end

  def listing_name
    full_name
  end

  def players_count
    model.players.count
  end

  def icon_class
    :users
  end

  def any_image_url
    logo_url.presence || first_discord_guild_icon_image_url || default_logo_image_url
  end

  def any_image_tag(options = {})
    h.image_tag_with_max_size any_image_url, options.merge(class: 'avatar')
  end

  def logo_image_tag(options = {})
    return nil unless model.logo.attached?

    url = model.logo.service_url
    h.image_tag_with_max_size url, options.merge(class: 'avatar')
  end

  def first_discord_guild_icon_image_url(size = nil)
    return nil if model.first_discord_guild.nil?

    model.first_discord_guild.decorate.icon_image_url(size)
  end

  def default_logo_image_url
    'default-team-logo.png'
  end

  def roster_image_tag(options = {})
    return nil unless model.roster.attached?

    url = model.roster.service_url
    h.image_tag_with_max_size url, options
  end

  def as_autocomplete_result
    h.tag.div class: 'team' do
      h.tag.div class: :name do
        full_name
      end
    end
  end

  def link(options = {})
    super({ label: short_name_with_logo(max_width: 32, max_height: 32) }.merge(options))
  end

  def badges
    (
      '' + (
        is_offline? ? h.tag.span('Offline', class: 'badge badge-success') : ''
      ) + ' ' + (
        is_online? ? h.tag.span('Online', class: 'badge badge-warning') : ''
      ) + ' ' + (
        is_sponsor? ? h.tag.span('Sponsor', class: 'badge badge-dark') : ''
      )
    ).html_safe
  end
end
