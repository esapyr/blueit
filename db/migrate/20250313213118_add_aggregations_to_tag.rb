class AddAggregationsToTag < ActiveRecord::Migration[8.0]
  def up
    Tag.create_continuous_aggregates
  end

  def down
    Tag.drop_continuous_aggregates
  end
end
