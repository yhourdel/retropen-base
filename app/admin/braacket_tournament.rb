ActiveAdmin.register BraacketTournament do
  decorate_with ActiveAdmin::BraacketTournamentDecorator

  is_bracket

  menu parent: '<img src="https://braacket.com/favicon.ico" height="16" class="logo"/>Braacket'.html_safe,
       label: '<i class="fas fa-fw fa-chess"></i>Tournois'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :tournament_event, :duo_tournament_event

  index do
    selectable_column
    id_column
    column :any_tournament_event do |decorated|
      decorated.any_tournament_event_admin_link
    end
    column 'Tournoi', sortable: :slug do |decorated|
      decorated.braacket_link
    end
    column :start_at do |decorated|
      decorated.start_at_date
    end
    column :participants_count
    BraacketTournament::PARTICIPANT_NAMES.each do |participant_name|
      column participant_name
    end
    column :is_ignored
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  filter :slug
  filter :name
  filter :start_at
  filter :is_ignored
  filter :participants_count
  filter :created_at

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :braacket_url, placeholder: 'https://braacket.com/...'
    end
    f.actions
  end

  permit_params :braacket_id, :braacket_url

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :slug
      row 'Tournoi' do |decorated|
        decorated.braacket_link
      end
      row :start_at
      row :participants_count
      BraacketTournament::PARTICIPANT_NAMES.each do |participant_name|
        row participant_name
      end
      row :tournament_event do |decorated|
        decorated.tournament_event_admin_link
      end
      row :duo_tournament_event do |decorated|
        decorated.duo_tournament_event_admin_link
      end
      row :is_ignored
      row :created_at
      row :updated_at
    end
  end
end
