class CreateTags < ActiveRecord::Migration[8.0]
  HYPER_TABLE_OPTIONS = {
    chunk_time_interval: '1 day',     # create a new table for each day
    compress_after: '7 days',         # start compression after 7 days
    time_column: Tag::TIME_COLUMN,        # partition data by this column
    compress_segmentby: Tag::SEGMENTATION_COLUMN, # columnar compression key
    compress_orderby: "#{Tag::TIME_COLUMN} DESC", # compression order
    drop_after: Tag::DATA_RETENTION_INTERVAL
  }

  def change
    create_table :tags, id: false, hypertable: HYPER_TABLE_OPTIONS do |t|
      t.text :did
      t.text :rkey
      t.text :text
      t.timestamptz :posted_at
    end
  end
end
