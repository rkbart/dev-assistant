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

ActiveRecord::Schema[8.1].define(version: 2026_05_11_070143) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "code_chunks", force: :cascade do |t|
    t.string "chunk_type"
    t.text "content"
    t.datetime "created_at", null: false
    t.jsonb "embedding"
    t.integer "end_line"
    t.string "file_hash"
    t.string "file_path"
    t.string "language"
    t.integer "start_line"
    t.string "symbol_name"
    t.datetime "updated_at", null: false
    t.index ["chunk_type"], name: "index_code_chunks_on_chunk_type"
    t.index ["file_hash"], name: "index_code_chunks_on_file_hash"
    t.index ["language"], name: "index_code_chunks_on_language"
    t.index ["symbol_name"], name: "index_code_chunks_on_symbol_name"
  end
end
