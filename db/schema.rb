# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_03_13_213118) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "timescaledb"
  enable_extension "timescaledb_toolkit"

  create_table "comments", force: :cascade do |t|
    t.string "did"
    t.string "rkey"
    t.string "text"
    t.boolean "root", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rkey"], name: "index_comments_on_rkey"
  end

  create_table "links", id: false, force: :cascade do |t|
    t.timestamptz "posted_at", null: false
    t.text "did"
    t.text "rkey"
    t.text "url"
    t.text "host"
    t.index ["posted_at"], name: "links_posted_at_idx", order: :desc
  end

  create_table "tags", id: false, force: :cascade do |t|
    t.text "did"
    t.text "rkey"
    t.text "text"
    t.timestamptz "posted_at", null: false
    t.index ["posted_at"], name: "tags_posted_at_idx", order: :desc
  end
  create_hypertable "links", time_column: "posted_at", chunk_time_interval: "1 day", compress_segmentby: "did", compress_orderby: "posted_at DESC", compress_after: "P7D"
  create_hypertable "tags", time_column: "posted_at", chunk_time_interval: "1 day", compress_segmentby: "did", compress_orderby: "posted_at DESC", compress_after: "P7D"

  create_retention_policy "links", drop_after: "P1Y"
  create_retention_policy "tags", drop_after: "P1Y"
  create_continuous_aggregate("link_post_counts_per_minute", <<-SQL, refresh_policies: { start_offset: "INTERVAL 'PT3M'", end_offset: "INTERVAL 'PT1M'", schedule_interval: "INTERVAL '60'"}, materialized_only: true, finalized: true)
    SELECT time_bucket('PT1M'::interval, posted_at) AS posted_at,
      url,
      count(url) AS count
     FROM links
    GROUP BY (time_bucket('PT1M'::interval, posted_at)), url
  SQL

  create_continuous_aggregate("link_post_counts_per_hour", <<-SQL, refresh_policies: { start_offset: "INTERVAL 'PT3H'", end_offset: "INTERVAL 'PT1H'", schedule_interval: "INTERVAL '60'"}, materialized_only: true, finalized: true)
    SELECT time_bucket('PT1H'::interval, posted_at) AS posted_at,
      url,
      count(url) AS count
     FROM link_post_counts_per_minute
    GROUP BY (time_bucket('PT1H'::interval, posted_at)), url
  SQL

  create_continuous_aggregate("link_post_counts_per_day", <<-SQL, refresh_policies: { start_offset: "INTERVAL 'P3D'", end_offset: "INTERVAL 'P1D'", schedule_interval: "INTERVAL '60'"}, materialized_only: true, finalized: true)
    SELECT time_bucket('P1D'::interval, posted_at) AS posted_at,
      url,
      count(url) AS count
     FROM link_post_counts_per_hour
    GROUP BY (time_bucket('P1D'::interval, posted_at)), url
  SQL

  create_continuous_aggregate("host_counts_per_minute", <<-SQL, refresh_policies: { start_offset: "INTERVAL 'PT3M'", end_offset: "INTERVAL 'PT1M'", schedule_interval: "INTERVAL '60'"}, materialized_only: true, finalized: true)
    SELECT time_bucket('PT1M'::interval, posted_at) AS posted_at,
      host,
      count(host) AS count
     FROM links
    GROUP BY (time_bucket('PT1M'::interval, posted_at)), host
  SQL

  create_continuous_aggregate("host_counts_per_hour", <<-SQL, refresh_policies: { start_offset: "INTERVAL 'PT3H'", end_offset: "INTERVAL 'PT1H'", schedule_interval: "INTERVAL '60'"}, materialized_only: true, finalized: true)
    SELECT time_bucket('PT1H'::interval, posted_at) AS posted_at,
      host,
      count(host) AS count
     FROM host_counts_per_minute
    GROUP BY (time_bucket('PT1H'::interval, posted_at)), host
  SQL

  create_continuous_aggregate("host_counts_per_day", <<-SQL, refresh_policies: { start_offset: "INTERVAL 'P3D'", end_offset: "INTERVAL 'P1D'", schedule_interval: "INTERVAL '60'"}, materialized_only: true, finalized: true)
    SELECT time_bucket('P1D'::interval, posted_at) AS posted_at,
      host,
      count(host) AS count
     FROM host_counts_per_hour
    GROUP BY (time_bucket('P1D'::interval, posted_at)), host
  SQL

  create_continuous_aggregate("link_poster_counts_per_minute", <<-SQL, refresh_policies: { start_offset: "INTERVAL 'PT3M'", end_offset: "INTERVAL 'PT1M'", schedule_interval: "INTERVAL '60'"}, materialized_only: true, finalized: true)
    SELECT time_bucket('PT1M'::interval, posted_at) AS posted_at,
      did,
      count(did) AS count
     FROM links
    GROUP BY (time_bucket('PT1M'::interval, posted_at)), did
  SQL

  create_continuous_aggregate("link_poster_counts_per_hour", <<-SQL, refresh_policies: { start_offset: "INTERVAL 'PT3H'", end_offset: "INTERVAL 'PT1H'", schedule_interval: "INTERVAL '60'"}, materialized_only: true, finalized: true)
    SELECT time_bucket('PT1H'::interval, posted_at) AS posted_at,
      did,
      count(did) AS count
     FROM link_poster_counts_per_minute
    GROUP BY (time_bucket('PT1H'::interval, posted_at)), did
  SQL

  create_continuous_aggregate("link_poster_counts_per_day", <<-SQL, refresh_policies: { start_offset: "INTERVAL 'P3D'", end_offset: "INTERVAL 'P1D'", schedule_interval: "INTERVAL '60'"}, materialized_only: true, finalized: true)
    SELECT time_bucket('P1D'::interval, posted_at) AS posted_at,
      did,
      count(did) AS count
     FROM link_poster_counts_per_hour
    GROUP BY (time_bucket('P1D'::interval, posted_at)), did
  SQL

  create_continuous_aggregate("tag_post_counts_per_minute", <<-SQL, refresh_policies: { start_offset: "INTERVAL 'PT3M'", end_offset: "INTERVAL 'PT1M'", schedule_interval: "INTERVAL '60'"}, materialized_only: true, finalized: true)
    SELECT time_bucket('PT1M'::interval, posted_at) AS posted_at,
      text,
      count(*) AS count
     FROM tags
    GROUP BY (time_bucket('PT1M'::interval, posted_at)), text
  SQL

  create_continuous_aggregate("tag_post_counts_per_hour", <<-SQL, refresh_policies: { start_offset: "INTERVAL 'PT3H'", end_offset: "INTERVAL 'PT1H'", schedule_interval: "INTERVAL '60'"}, materialized_only: true, finalized: true)
    SELECT time_bucket('PT1H'::interval, posted_at) AS posted_at,
      text,
      count(*) AS count
     FROM tag_post_counts_per_minute
    GROUP BY (time_bucket('PT1H'::interval, posted_at)), text
  SQL

  create_continuous_aggregate("tag_post_counts_per_day", <<-SQL, refresh_policies: { start_offset: "INTERVAL 'P3D'", end_offset: "INTERVAL 'P1D'", schedule_interval: "INTERVAL '60'"}, materialized_only: true, finalized: true)
    SELECT time_bucket('P1D'::interval, posted_at) AS posted_at,
      text,
      count(*) AS count
     FROM tag_post_counts_per_hour
    GROUP BY (time_bucket('P1D'::interval, posted_at)), text
  SQL

end
