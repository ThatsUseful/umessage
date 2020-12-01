# == Schema Information
#
# Table name: chat_handle_join
#
#  chat_id   :integer
#  handle_id :integer
#
# Indexes
#
#  chat_handle_join_idx_handle_id  (handle_id)
#
# Foreign Keys
#
#  chat_id    (chat_id => chat.ROWID) ON DELETE => cascade
#  handle_id  (handle_id => handle.ROWID) ON DELETE => cascade
#

class ChatHandle < ApplicationRecord
  self.table_name = 'chat_handle_join'

  belongs_to :chat
  belongs_to :handle
end
