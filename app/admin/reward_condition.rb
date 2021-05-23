ActiveAdmin.register RewardCondition do

  decorate_with ActiveAdmin::RewardConditionDecorator

  has_paper_trail

  menu parent: '<i class="fas fa-fw fa-chess-rook"></i>Compétition 1v1'.html_safe,
       label: '<i class="fas fa-fw fa-fire"></i>Conditions de récompense'.html_safe,
       priority: 3

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  config.sort_order = 'points_asc'

  index do
    selectable_column
    id_column
    column :rank do |decorated|
      decorated.rank_name
    end
    column :size_min
    column :size_max
    column :reward do |decorated|
      decorated.reward_admin_link
    end
    column :points
    column :player_reward_conditions do |decorated|
      decorated.player_reward_conditions_admin_link
    end
    actions
  end

  scope :all, default: true

  scope :online
  scope :offline

  filter :rank,
         as: :select,
         collection: proc { reward_condition_rank_select_collection },
         input_html: { multiple: true, data: { select2: {} } }
  filter :size_min
  filter :size_max
  filter :reward,
         as: :select,
         collection: proc { reward_condition_reward_select_collection },
         input_html: { multiple: true, data: { select2: {} } }
  filter :points

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :rank,
              as: :select,
              collection: reward_condition_rank_select_collection,
              input_html: { data: { select2: {} } },
              include_blank: false
      f.input :size_min
      f.input :size_max
      f.input :reward,
              collection: reward_condition_reward_select_collection,
              input_html: { data: { select2: {} } }
      f.input :points
    end
    f.actions
  end

  permit_params :rank, :size_min, :size_max, :reward_id, :points

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :rank do |decorated|
        decorated.rank_name
      end
      row :size_min
      row :size_max
      row :reward do |decorated|
        decorated.reward_admin_link
      end
      row :points
      row :player_reward_conditions do |decorated|
        decorated.player_reward_conditions_admin_link
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

end
