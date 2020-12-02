module ChatsHelper
  CONTACTS = Contacts.new

  def attachment_image_tag(attachment, **opts)
    path = attachment.filename.gsub(/.+Attachments\//, "") rescue nil

    if path
      path = "/images/message_attachments/#{path}"
      path = asset_path(path, skip_pipeline: true)
      link_to(image_tag(path, **opts), path, target: "_blank")
    end
  end

  def datetime(datetime)
    format = datetime.today? ? :conversations_today : :conversations_longer
    l(datetime, format: format)
  end
end
