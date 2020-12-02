# == Schema Information
#
# Table name: message
#
#  ROWID                             :integer          primary key
#  account                           :text
#  account_guid                      :text
#  associated_message_guid           :text
#  associated_message_range_length   :integer          default(0)
#  associated_message_range_location :integer          default(0)
#  associated_message_type           :integer          default(0)
#  attributedBody                    :binary
#  cache_has_attachments             :integer          default(0)
#  cache_roomnames                   :text
#  ck_record_change_tag              :text
#  ck_sync_state                     :integer          default(0)
#  country                           :text
#  date                              :integer
#  date_delivered                    :integer
#  date_played                       :integer
#  date_read                         :integer
#  error                             :integer          default(0)
#  expire_state                      :integer          default(0)
#  group_action_type                 :integer          default(0)
#  group_title                       :text
#  guid                              :text             not null
#  has_dd_results                    :integer          default(0)
#  has_unseen_mention                :integer          default(0)
#  is_archive                        :integer          default(0)
#  is_audio_message                  :integer          default(0)
#  is_auto_reply                     :integer          default(0)
#  is_corrupt                        :integer          default(0)
#  is_delayed                        :integer          default(0)
#  is_delivered                      :integer          default(0)
#  is_emote                          :integer          default(0)
#  is_empty                          :integer          default(0)
#  is_expirable                      :integer          default(0)
#  is_finished                       :integer          default(0)
#  is_forward                        :integer          default(0)
#  is_from_me                        :integer          default(0)
#  is_played                         :integer          default(0)
#  is_prepared                       :integer          default(0)
#  is_read                           :integer          default(0)
#  is_sent                           :integer          default(0)
#  is_service_message                :integer          default(0)
#  is_spam                           :integer          default(0)
#  is_system_message                 :integer          default(0)
#  item_type                         :integer          default(0)
#  message_action_type               :integer          default(0)
#  message_source                    :integer          default(0)
#  message_summary_info              :binary
#  other_handle                      :integer          default(0)
#  payload_data                      :binary
#  replace                           :integer          default(0)
#  reply_to_guid                     :text
#  service                           :text
#  service_center                    :text
#  share_direction                   :integer          default(0)
#  share_status                      :integer          default(0)
#  sr_ck_record_change_tag           :text
#  sr_ck_sync_state                  :integer          default(0)
#  subject                           :text
#  text                              :text
#  thread_originator_guid            :text
#  thread_originator_part            :text
#  time_expressive_send_played       :integer
#  type                              :integer          default(0)
#  version                           :integer          default(0)
#  was_data_detected                 :integer          default(0)
#  was_deduplicated                  :integer          default(0)
#  was_downgraded                    :integer          default(0)
#  balloon_bundle_id                 :text
#  ck_record_id                      :text
#  destination_caller_id             :text
#  expressive_send_style_id          :text
#  handle_id                         :integer          default(0)
#  sort_id                           :integer
#  sr_ck_record_id                   :text
#
# Indexes
#
#  message_idx_associated_message               (associated_message_guid)
#  message_idx_cache_has_attachments            (cache_has_attachments)
#  message_idx_date                             (date)
#  message_idx_expire_state                     (expire_state)
#  message_idx_failed                           (is_finished,is_from_me,error)
#  message_idx_handle                           (handle_id,date)
#  message_idx_handle_id                        (handle_id)
#  message_idx_isRead_isFromMe_itemType         (is_read,is_from_me,item_type)
#  message_idx_is_read                          (is_read,is_from_me,is_finished)
#  message_idx_is_sent_is_from_me_error         (is_sent,is_from_me,error)
#  message_idx_other_handle                     (other_handle)
#  message_idx_thread_originator_guid           (thread_originator_guid)
#  message_idx_undelivered_one_to_one_imessage  (cache_roomnames,service,is_sent,is_delivered,was_downgraded,item_type) WHERE cache_roomnames IS NULL AND service = 'iMessage' AND is_sent = 1 AND is_delivered = 0 AND was_downgraded = 0 AND item_type == 0
#  message_idx_was_downgraded                   (was_downgraded)
#

class Message < ApplicationRecord
  self.table_name = 'message'
  self.inheritance_column = 'message_type' # "type" is a reserved column name

  belongs_to :handle

  has_many :chat_messages
  has_many :chats, through: :chat_messages

  has_many :message_attachments
  has_many :attachments, through: :message_attachments

  after_initialize :parse_payload_data

  attribute :parsed_payload_data 
  attribute :title
  attribute :summary
  attribute :item_type
  attribute :item_url
  attribute :site_name
  attribute :twitter
  attribute :facebook
  attribute :icon_original_url
  attribute :icon_cached
  attribute :image_original_url
  attribute :image_cached

  class << self
    def for_chat
      select(
        <<~SQL
          message.ROWID,
          text,
          is_from_me,
          handle.id AS handle_identifier,
          cache_has_attachments,
          balloon_bundle_id,
          payload_data,
          datetime(
            message.date / 1000000000 + strftime("%s", "2001-01-01"),
            "unixepoch", "localtime"
          ) AS sent_at
        SQL
      )
        .includes(:attachments, chats: :handles)
        .joins("LEFT JOIN handle on handle.ROWID = message.handle_id")
    end
  end

  def is_balloon?
    return self[:payload_data] != nil
  end

  def parse_payload_data
    if self[:payload_data]
      logger.info("New attachment")

      # Instantiate a new list
      cf_list = CFPropertyList::List.new()
      cf_list.load_binary_str(self[:payload_data])

      # Get the objects
      objects = cf_list.value.value["$objects"].value
      
      # Get the root node
      top = cf_list.value.value["$top"]
      root_node = top.value["root"]
      root_data_idx = root_node.value

      # Get the root data node
      root_data_node = objects[root_data_idx].value

      # Find out where the metadata is
      metadata_node = root_data_node["richLinkMetadata"].value

      # Get the metadata node
      metadata = objects[metadata_node]

      # Flatten
      flattened = flatten_object(objects, metadata)
      logger.info(flattened.inspect)

      # Set attr
      self[:parsed_payload_data] = flattened
      self[:title] = flattened["title"]
      self[:summary] = flattened["summary"]
      self[:item_type] = flattened["itemType"]
      self[:item_url] = flattened["URL"]["NS.relative"]
      self[:site_name] = flattened["siteName"]
      self[:twitter] = flattened["creatorTwitterUsername"]
      self[:facebook] = flattened["creatorFacebookProfile"]

      if flattened["iconMetadata"]
        self[:icon_original_url] = flattened["iconMetadata"]["URL"]["NS.relative"]
        cache_index = flattened["icon"]["richLinkImageAttachmentSubstituteIndex"]
        self[:icon_cached] = self.attachments[cache_index]
      end

      if flattened["imageMetadata"]
        self[:image_original_url] = flattened["imageMetadata"]["URL"]["NS.relative"]
        cache_index = flattened["image"]["richLinkImageAttachmentSubstituteIndex"]
        self[:image_cached] = self.attachments[cache_index]
      end

      icon = flattened["icon"]["richLinkImageAttachmentSubstituteIndex"]
    end
  end

  def flatten_object(objects, object)
    return object.value if object.is_a?(CFPropertyList::CFString)

    # If there is a CFUid, recurse that entry. Else, if not, this is the end
    if object.is_a?(CFPropertyList::CFDictionary) then
      dict = object.value
      dict.each_pair do |k,v|
        if k.match(/class/) then
          dict.delete(k)

        elsif v.is_a?(CFPropertyList::CFUid) then
          dict[k] = flatten_object(objects, objects[v.value])

        elsif v.is_a?(CFPropertyList::CFString) then
          dict[k] = v.value

        elsif v.is_a?(CFPropertyList::CFInteger) then
          dict[k] = v.value

        elsif v.is_a?(CFPropertyList::CFDictionary) then
          dict[k] = flatten_object(objects, v)

        elsif v.is_a?(CFPropertyList::CFArray) then
          dict[k] = flatten_object(objects, v)
        end
      end

    elsif object.is_a?(CFPropertyList::CFArray) then
      object.value.each_with_index do |item, idx|
        object.value[idx] = flatten_object(objects, item)
      end
    end
  end

  def identifier
    if is_from_me?
      "Me"
    elsif name = ChatsHelper::CONTACTS.by_phone(handle_identifier)
      name
    else
      handle_identifier
    end
  end

  def text
    if cache_has_attachments? || self[:text] == "￼"
      "[Attachment]"
    else
      super&.strip || ""
    end
  end

  def text_for_chat
    text == "[Attachment]" ? "" : text
  end

  def as_json(opts)
    super(opts.merge(methods: :identifier))
  end
end
