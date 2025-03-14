class Link < ApplicationRecord
  extend Timescaledb::ActsAsHypertable
  include Timescaledb::ContinuousAggregatesHelper

  DATA_RETENTION_INTERVAL = "1 year"
  TIME_COLUMN = :posted_at
  SEGMENTATION_COLUMN = :did

  acts_as_hypertable time_column: TIME_COLUMN, segment_by: SEGMENTATION_COLUMN

  scope :link_post_counts, -> { select("url, count(*)").group(:url).having("count(host) > 1") }
  scope :host_counts, -> { select("host, count(host)").group(:host).having("count(host) > 1") }
  scope :link_poster_counts, -> { select("did, count(did)").group(:did).having("count(did) > 1") }

  continuous_aggregates scopes: [ :link_post_counts, :host_counts, :link_poster_counts ],
    timeframes: [ :minute, :hour, :day ],
    refresh_policy: {
      minute: {
        start_offset: "3 minute",
        end_offset: "1 minute",
        schedule_interval: "1 minute"
      },
      hour: {
        start_offset: "3 hours",
        end_offset: "1 hour",
        schedule_interval: "1 minute"
      },
      day: {
        start_offset: "3 day",
        end_offset: "1 day",
        schedule_interval: "1 minute"
      }
    }

  # TODO: get the foreign key working with the hypertable
  def comments
    Comment.where(rkey: Link.where(url:).select(:rkey)).uniq { |c| c.text }
  end

  def tags
    Tag.where(rkey: Link.where(url:).select(:rkey))
  end
end
