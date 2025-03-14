class CreateLinks < ActiveRecord::Migration[8.0]
  HYPER_TABLE_OPTIONS = {
    chunk_time_interval: '1 day',     # create a new table for each day
    compress_after: '7 days',         # start compression after 7 days
    time_column: Link::TIME_COLUMN,        # partition data by this column
    compress_segmentby: Link::SEGMENTATION_COLUMN, # columnar compression key
    compress_orderby: "#{Link::TIME_COLUMN} DESC", # compression order
    drop_after: Link::DATA_RETENTION_INTERVAL
  }

  def change
    create_table :links, id: false, hypertable: HYPER_TABLE_OPTIONS do |t|
      t.timestamptz :posted_at
      t.text :did
      t.text :rkey
      t.text :url
      t.text :host
    end
  end
end
