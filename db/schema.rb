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

ActiveRecord::Schema[8.0].define(version: 2025_03_06_165902) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "timescaledb"
  enable_extension "timescaledb_toolkit"

  create_table "links", id: false, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.text "url"
    t.text "scheme"
    t.text "host"
    t.text "path"
    t.text "query"
    t.index ["created_at"], name: "links_created_at_idx", order: :desc
  end
  create_hypertable "links", time_column: "created_at", chunk_time_interval: "1 day", compress_segmentby: "host", compress_orderby: "created_at DESC", compress_after: "P7D"

  create_retention_policy "links", drop_after: "P6M"
end
