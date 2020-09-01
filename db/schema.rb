# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  create_table "_SqliteDatabaseProperties", id: false, force: :cascade do |t|
    t.text "key"
    t.text "value"
  end

  create_table "attachment", primary_key: "ROWID", force: :cascade do |t|
    t.text "guid", null: false
    t.integer "created_date", default: 0
    t.integer "start_date", default: 0
    t.text "filename"
    t.text "uti"
    t.text "mime_type"
    t.integer "transfer_state", default: 0
    t.integer "is_outgoing", default: 0
    t.binary "user_info"
    t.text "transfer_name"
    t.integer "total_bytes", default: 0
    t.integer "is_sticker", default: 0
    t.binary "sticker_user_info"
    t.binary "attribution_info"
    t.integer "hide_attachment", default: 0
    t.integer "ck_sync_state", default: 0
    t.binary "ck_server_change_token_blob"
    t.text "ck_record_id"
    t.text "original_guid", null: false
    t.integer "sr_ck_sync_state", default: 0
    t.binary "sr_ck_server_change_token_blob"
    t.text "sr_ck_record_id"
    t.index ["hide_attachment", "ck_sync_state", "transfer_state"], name: "attachment_idx_purged_attachments", where: "hide_attachment=0 AND ck_sync_state=1 AND transfer_state=0"
  end

  create_table "chat", primary_key: "ROWID", force: :cascade do |t|
    t.text "guid", null: false
    t.integer "style"
    t.integer "state"
    t.text "account_id"
    t.binary "properties"
    t.text "chat_identifier"
    t.text "service_name"
    t.text "room_name"
    t.text "account_login"
    t.integer "is_archived", default: 0
    t.text "last_addressed_handle"
    t.text "display_name"
    t.text "group_id"
    t.integer "is_filtered"
    t.integer "successful_query"
    t.text "engram_id"
    t.text "server_change_token"
    t.integer "ck_sync_state", default: 0
    t.text "original_group_id"
    t.integer "last_read_message_timestamp", default: 0
    t.text "sr_server_change_token"
    t.integer "sr_ck_sync_state", default: 0
    t.text "cloudkit_record_id"
    t.text "sr_cloudkit_record_id"
    t.text "last_addressed_sim_id"
    t.integer "is_blackholed", default: 0
    t.index ["chat_identifier", "service_name"], name: "chat_idx_chat_identifier_service_name"
    t.index ["chat_identifier"], name: "chat_idx_chat_identifier"
    t.index ["is_archived"], name: "chat_idx_is_archived"
    t.index ["room_name", "service_name"], name: "chat_idx_chat_room_name_service_name"
  end

  create_table "chat_handle_join", id: false, force: :cascade do |t|
    t.integer "chat_id"
    t.integer "handle_id"
    t.index ["handle_id"], name: "chat_handle_join_idx_handle_id"
  end

  create_table "chat_message_join", primary_key: ["chat_id", "message_id"], force: :cascade do |t|
    t.integer "chat_id"
    t.integer "message_id"
    t.integer "message_date", default: 0
    t.index ["chat_id", "message_date", "message_id"], name: "chat_message_join_idx_message_date_id_chat_id"
    t.index ["chat_id"], name: "chat_message_join_idx_chat_id"
    t.index ["message_id"], name: "chat_message_join_idx_message_id_only"
  end

  create_table "deleted_messages", primary_key: "ROWID", force: :cascade do |t|
    t.text "guid", null: false
  end

  create_table "handle", primary_key: "ROWID", force: :cascade do |t|
    t.text "id", null: false
    t.text "country"
    t.text "service", null: false
    t.text "uncanonicalized_id"
    t.text "person_centric_id"
  end

  create_table "kvtable", primary_key: "ROWID", force: :cascade do |t|
    t.text "key", null: false
    t.binary "value", null: false
  end

  create_table "message", primary_key: "ROWID", force: :cascade do |t|
    t.text "guid", null: false
    t.text "text"
    t.integer "replace", default: 0
    t.text "service_center"
    t.integer "handle_id", default: 0
    t.text "subject"
    t.text "country"
    t.binary "attributedBody"
    t.integer "version", default: 0
    t.integer "type", default: 0
    t.text "service"
    t.text "account"
    t.text "account_guid"
    t.integer "error", default: 0
    t.integer "date"
    t.integer "date_read"
    t.integer "date_delivered"
    t.integer "is_delivered", default: 0
    t.integer "is_finished", default: 0
    t.integer "is_emote", default: 0
    t.integer "is_from_me", default: 0
    t.integer "is_empty", default: 0
    t.integer "is_delayed", default: 0
    t.integer "is_auto_reply", default: 0
    t.integer "is_prepared", default: 0
    t.integer "is_read", default: 0
    t.integer "is_system_message", default: 0
    t.integer "is_sent", default: 0
    t.integer "has_dd_results", default: 0
    t.integer "is_service_message", default: 0
    t.integer "is_forward", default: 0
    t.integer "was_downgraded", default: 0
    t.integer "is_archive", default: 0
    t.integer "cache_has_attachments", default: 0
    t.text "cache_roomnames"
    t.integer "was_data_detected", default: 0
    t.integer "was_deduplicated", default: 0
    t.integer "is_audio_message", default: 0
    t.integer "is_played", default: 0
    t.integer "date_played"
    t.integer "item_type", default: 0
    t.integer "other_handle", default: 0
    t.text "group_title"
    t.integer "group_action_type", default: 0
    t.integer "share_status", default: 0
    t.integer "share_direction", default: 0
    t.integer "is_expirable", default: 0
    t.integer "expire_state", default: 0
    t.integer "message_action_type", default: 0
    t.integer "message_source", default: 0
    t.text "associated_message_guid"
    t.integer "associated_message_type", default: 0
    t.text "balloon_bundle_id"
    t.binary "payload_data"
    t.text "expressive_send_style_id"
    t.integer "associated_message_range_location", default: 0
    t.integer "associated_message_range_length", default: 0
    t.integer "time_expressive_send_played"
    t.binary "message_summary_info"
    t.integer "ck_sync_state", default: 0
    t.text "ck_record_id"
    t.text "ck_record_change_tag"
    t.text "destination_caller_id"
    t.integer "sr_ck_sync_state", default: 0
    t.text "sr_ck_record_id"
    t.text "sr_ck_record_change_tag"
    t.integer "is_corrupt", default: 0
    t.text "reply_to_guid"
    t.integer "sort_id"
    t.integer "is_spam", default: 0
    t.index ["associated_message_guid"], name: "message_idx_associated_message"
    t.index ["cache_has_attachments"], name: "message_idx_cache_has_attachments"
    t.index ["cache_roomnames", "service", "is_sent", "is_delivered", "was_downgraded", "item_type"], name: "message_idx_undelivered_one_to_one_imessage", where: "cache_roomnames IS NULL AND service = 'iMessage' AND is_sent = 1 AND is_delivered = 0 AND was_downgraded = 0 AND item_type == 0"
    t.index ["date"], name: "message_idx_date"
    t.index ["expire_state"], name: "message_idx_expire_state"
    t.index ["handle_id", "date"], name: "message_idx_handle"
    t.index ["handle_id"], name: "message_idx_handle_id"
    t.index ["is_finished", "is_from_me", "error"], name: "message_idx_failed"
    t.index ["is_read", "is_from_me", "is_finished"], name: "message_idx_is_read"
    t.index ["is_read", "is_from_me", "item_type"], name: "message_idx_isRead_isFromMe_itemType"
    t.index ["is_sent", "is_from_me", "error"], name: "message_idx_is_sent_is_from_me_error"
    t.index ["other_handle"], name: "message_idx_other_handle"
    t.index ["was_downgraded"], name: "message_idx_was_downgraded"
  end

  create_table "message_attachment_join", id: false, force: :cascade do |t|
    t.integer "message_id"
    t.integer "attachment_id"
    t.index ["attachment_id"], name: "message_attachment_join_idx_attachment_id"
    t.index ["message_id"], name: "message_attachment_join_idx_message_id"
  end

  create_table "message_processing_task", primary_key: "ROWID", force: :cascade do |t|
    t.text "guid", null: false
    t.integer "task_flags", null: false
    t.index ["guid", "task_flags"], name: "message_processing_task_idx_guid_task_flags"
  end

# Could not dump table "sqlite_stat1" because of following StandardError
#   Unknown type '' for column 'tbl'

  create_table "sync_deleted_attachments", primary_key: "ROWID", force: :cascade do |t|
    t.text "guid", null: false
    t.text "recordID"
  end

  create_table "sync_deleted_chats", primary_key: "ROWID", force: :cascade do |t|
    t.text "guid", null: false
    t.text "recordID"
    t.integer "timestamp"
  end

  create_table "sync_deleted_messages", primary_key: "ROWID", force: :cascade do |t|
    t.text "guid", null: false
    t.text "recordID"
  end

end
