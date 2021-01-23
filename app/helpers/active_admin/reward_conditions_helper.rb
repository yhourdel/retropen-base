module ActiveAdmin::RewardConditionsHelper

  def reward_condition_reward_select_collection
    Reward.order(:name).map do |reward|
      [
        reward.name,
        reward.id
      ]
    end
  end

  def reward_condition_rank_select_collection
    RewardCondition::RANKS.map do |v|
      [
        RewardConditionDecorator.rank_value_name(v),
        v
      ]
    end
  end

end
