# == Schema Information
#
# Table name: handle
#
#  id                 :text             not null
#  ROWID              :integer          primary key
#  country            :text
#  service            :text             not null
#  person_centric_id  :text
#  uncanonicalized_id :text
#

class Handle < ApplicationRecord
  self.table_name = 'handle'

  default_scope { select("*, id AS chat_identifier") }

  has_many :chat_handles
  has_many :chats, through: :chat_handles

  def self.select_identifier
    select("id AS identifier")
  end
end
