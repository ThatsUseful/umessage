#! /bin/sh

for file in ~/Library/Messages/Attachments/**/*pluginPayloadAttachment; do file $file >> ~/Desktop/Attachments.txt; done