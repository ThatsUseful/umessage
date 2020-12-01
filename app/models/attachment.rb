# == Schema Information
#
# Table name: attachment
#
#  ROWID                          :integer          primary key
#  attribution_info               :binary
#  ck_server_change_token_blob    :binary
#  ck_sync_state                  :integer          default(0)
#  created_date                   :integer          default(0)
#  filename                       :text
#  guid                           :text             not null
#  hide_attachment                :integer          default(0)
#  is_outgoing                    :integer          default(0)
#  is_sticker                     :integer          default(0)
#  mime_type                      :text
#  original_guid                  :text             not null
#  sr_ck_server_change_token_blob :binary
#  sr_ck_sync_state               :integer          default(0)
#  start_date                     :integer          default(0)
#  sticker_user_info              :binary
#  total_bytes                    :integer          default(0)
#  transfer_name                  :text
#  transfer_state                 :integer          default(0)
#  user_info                      :binary
#  uti                            :text
#  ck_record_id                   :text
#  sr_ck_record_id                :text
#
# Indexes
#
#  attachment_idx_purged_attachments_v2  (hide_attachment,ck_sync_state,transfer_state) WHERE hide_attachment=0 AND (ck_sync_state=1 OR ck_sync_state=4) AND transfer_state=0
#

class Attachment < ApplicationRecord
  self.table_name = 'attachment'

  has_many :message_attachments
  has_many :messages, through: :message_attachments
end
