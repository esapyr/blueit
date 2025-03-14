class Tag < ApplicationRecord
  extend Timescaledb::ActsAsHypertable
  include Timescaledb::ContinuousAggregatesHelper

  DATA_RETENTION_INTERVAL = "1 year"
  TIME_COLUMN = :posted_at
  SEGMENTATION_COLUMN = :did

  acts_as_hypertable time_column: :posted_at, segment_by: SEGMENTATION_COLUMN

  scope :tag_post_counts, -> { select("text, count(*)").group(:text).having("count(text) > 1") }

  continuous_aggregates scopes: [ :tag_post_counts ],
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
end
