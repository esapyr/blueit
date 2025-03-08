class CreateLinks < ActiveRecord::Migration[8.0]
  HYPER_TABLE_OPTIONS = {
    time_column: 'created_at',        # partition data by this column
    chunk_time_interval: '1 day',     # create a new table for each day
    # TODO: is this a good field to group on?
    compress_segmentby: 'host', # columnar compression key
    compress_after: '7 days',         # start compression after 7 days
    compress_orderby: 'created_at DESC', # compression order
    drop_after: '6 months'            # delete data after 6 months
  }

  def change
    create_table :links, id: false, hypertable: HYPER_TABLE_OPTIONS do |t|
      t.timestamptz :created_at
      t.text :url
      t.text :scheme
      t.text :host
      t.text :path
      t.text :query
    end
  end
end
