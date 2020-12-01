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

  def attachment_plist_tag(data)
    cf_list = CFPropertyList::List.new(formatted: true)
    cf_list.load_binary_str(data)
    logger.info("New attachment")
    logger.info(cf_list.value.value["$objects"].value[6].value)
    logger.info(cf_list.value.value["$objects"].value[7].value)
    logger.info(cf_list.value.value["$objects"].value[4].value)
    logger.info(cf_list.value.value["$objects"].value[15].value)
    logger.info(cf_list.value.value["$objects"].value[21].value)

    # content_tag('pre', cf_list.to_str(CFPropertyList::List::FORMAT_XML), class: "list-group-item")
    content_tag('pre', cf_list.to_str(CFPropertyList::List::FORMAT_PLAIN), class: "list-group-item")

    # text = cf_list.
    # auto_link(simple_format(text), html: { target: "_blank" })
  end

  def datetime(datetime)
    format = datetime.today? ? :conversations_today : :conversations_longer
    l(datetime, format: format)
  end
end
