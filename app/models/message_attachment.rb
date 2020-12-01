# == Schema Information
#
# Table name: message_attachment_join
#
#  attachment_id :integer
#  message_id    :integer
#
# Indexes
#
#  message_attachment_join_idx_attachment_id  (attachment_id)
#  message_attachment_join_idx_message_id     (message_id)
#
# Foreign Keys
#
#  attachment_id  (attachment_id => attachment.ROWID) ON DELETE => cascade
#  message_id     (message_id => message.ROWID) ON DELETE => cascade
#

class MessageAttachment < ApplicationRecord
  self.table_name = 'message_attachment_join'

  belongs_to :message
  belongs_to :attachment
end
