# == Schema Information
#
# Table name: chat_message_join
#
#  message_date :integer          default(0)
#  chat_id      :integer
#  message_id   :integer
#
# Indexes
#
#  chat_message_join_idx_chat_id                  (chat_id)
#  chat_message_join_idx_message_date_id_chat_id  (chat_id,message_date,message_id)
#  chat_message_join_idx_message_id_only          (message_id)
#
# Foreign Keys
#
#  chat_id     (chat_id => chat.ROWID) ON DELETE => cascade
#  message_id  (message_id => message.ROWID) ON DELETE => cascade
#

class ChatMessage < ApplicationRecord
  self.table_name = 'chat_message_join'

  belongs_to :chat
  belongs_to :message

  def self.count_messages_for_recipient(recipient)
    chat_ids = Chat.fuzzy_search(recipient)
    where(chat_id: chat_ids).count
  end
end
