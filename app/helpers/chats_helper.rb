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

    # content_tag('pre', cf_list.to_str(CFPropertyList::List::FORMAT_XML), class: "list-group-item")
    content_tag('pre', flattened, class: "list-group-item")

    # text = cf_list.
    # auto_link(simple_format(text), html: { target: "_blank" })
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

  def datetime(datetime)
    format = datetime.today? ? :conversations_today : :conversations_longer
    l(datetime, format: format)
  end
end
