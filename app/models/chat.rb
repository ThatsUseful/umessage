# == Schema Information
#
# Table name: chat
#
#  ROWID                       :integer          primary key
#  account_login               :text
#  chat_identifier             :text
#  ck_sync_state               :integer          default(0)
#  display_name                :text
#  guid                        :text             not null
#  is_archived                 :integer          default(0)
#  is_blackholed               :integer          default(0)
#  is_filtered                 :integer
#  last_addressed_handle       :text
#  last_read_message_timestamp :integer          default(0)
#  properties                  :binary
#  room_name                   :text
#  server_change_token         :text
#  service_name                :text
#  sr_ck_sync_state            :integer          default(0)
#  sr_server_change_token      :text
#  state                       :integer
#  style                       :integer
#  successful_query            :integer
#  account_id                  :text
#  cloudkit_record_id          :text
#  engram_id                   :text
#  group_id                    :text
#  last_addressed_sim_id       :text
#  original_group_id           :text
#  sr_cloudkit_record_id       :text
#
# Indexes
#
#  chat_idx_chat_identifier               (chat_identifier)
#  chat_idx_chat_identifier_service_name  (chat_identifier,service_name)
#  chat_idx_chat_room_name_service_name   (room_name,service_name)
#  chat_idx_is_archived                   (is_archived)
#

class Chat < ApplicationRecord
  self.table_name = 'chat'

  has_many :chat_messages
  has_many :messages, through: :chat_messages

  has_many :chat_handles
  has_many :handles, through: :chat_handles

  after_initialize :parse_properties

  attribute :force_to_sms
  attribute :auto_spam_reported

  class << self
    def for_conversations
      select(
        <<~SQL
          chat.ROWID,
          chat.properties,
          (
            SELECT datetime(
              message.date / 1000000000 + strftime("%s", "2001-01-01"),
              "unixepoch", "localtime"
            ) AS date_utc
            FROM message
            JOIN chat_message_join ON chat_message_join.message_id = message.ROWID
            WHERE chat_message_join.chat_id = chat.ROWID
            ORDER BY date DESC
            LIMIT 1
          ) AS last_msg_at,
          (
            SELECT text
            FROM message
            JOIN chat_message_join ON chat_message_join.message_id = message.ROWID
            WHERE chat_message_join.chat_id = chat.ROWID
            ORDER BY date DESC
            LIMIT 1
          ) AS last_text
        SQL
      )
      .includes(:handles)
    end

    def fuzzy_search(params)
      results = []
      params.each { |param| results << "guid LIKE '%#{param}%'" }
      joined_results = results.join(' OR ')
      where(joined_results).pluck(:ROWID)
    end
  end

  def parse_properties
    if self[:properties]
      logger.info("Chat properties")

      # Instantiate a new list
      cf_list = CFPropertyList::List.new()
      cf_list.load_binary_str(self[:properties])

      # Flatten
      flattened = flatten_dict(cf_list.value.value)
      self[:force_to_sms] = flattened["shouldForceToSMS"]
      self[:auto_spam_reported] = flattened["hasBeenAutoSpamReported"]

      logger.info(cf_list.inspect)
    end
  end

  def flatten_dict(dict)
    dict.each_pair do |k,v|
      if v.is_a?(CFPropertyList::CFString) then
        dict[k] = v.value

      elsif v.is_a?(CFPropertyList::CFInteger) then
        dict[k] = v.value

      elsif v.is_a?(CFPropertyList::CFBoolean) then
        dict[k] = v.value

      elsif v.is_a?(CFPropertyList::CFDate) then
        dict[k] = v.value
      end
    end
  end

  def sanitized_guid
    guid.sub(/\w+;.;/, '')
  end

  def identifiers
    handles.map do |handle|
      if name = ChatsHelper::CONTACTS.by_phone(handle.chat_identifier)
        name
      else
        handle.chat_identifier
      end
    end.join(", ")
  end

  def unread_count
    @unread_count ||= redis.get("chat:#{id}:unread")&.to_i || 0
  end

  def unread_count=(count)
    redis.set("chat:#{id}:unread", count)
    @unread_count = count
  end

  def increment_unread_count!(by = 1)
    @unread_count = redis.incrby("chat:#{id}:unread", by).to_i
  end

  def reset_unread_count!
    redis.set("chat:#{id}:unread", 0)
    @unread_count = 0
  end
end
