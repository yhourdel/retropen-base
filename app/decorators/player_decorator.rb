class PlayerDecorator < BaseDecorator

  def characters_links
    model.characters.map do |character|
      character.decorate.admin_emoji_link
    end
  end

  def city_link
    model.city&.decorate&.admin_link
  end

  def team_link
    model.team&.decorate&.admin_link
  end

  def creator_link(options = {})
    model.creator.decorate.admin_link options
  end

  def discord_user_admin_link(options = {})
    model.discord_user&.decorate&.admin_link options
  end

  def icon_class
    :user
  end

  def as_autocomplete_result
    h.content_tag :div, class: :player do
      h.content_tag :div, class: :name do
        name
      end
    end
  end

end
