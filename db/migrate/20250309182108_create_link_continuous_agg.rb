class CreateLinkContinuousAgg < ActiveRecord::Migration[8.0]
  def up
    Link.create_continuous_aggregates
  end

  def down
    Link.drop_continuous_aggregates
  end
end
