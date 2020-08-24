ActiveAdmin.register Character do

  decorate_with CharacterDecorator

  has_paper_trail

  menu label: '<i class="fas fa-fw fa-gamepad"></i>Persos'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :emoji do |decorated|
      decorated.emoji_image_tag(max_height: '32px')
    end
    column :icon
    column :name
    column :players do |decorated|
      decorated.players_link
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  filter :name

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :emoji
      f.input :icon
      f.input :name
    end
    f.actions
  end

  permit_params :icon, :name, :emoji

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :emoji do |decorated|
        decorated.emoji_image_tag
      end
      row :icon
      row :name
      row :players do |decorated|
        decorated.players_link
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

end
