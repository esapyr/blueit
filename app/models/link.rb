class Link < ApplicationRecord
  extend Timescaledb::ActsAsHypertable

  acts_as_hypertable time_column: :created_at, segment_by: :host

  # NOTE: AR expects a primary key or default sort, so heres a default sort
  default_scope { order(created_at: :desc) }
end
