# frozen_string_literal: true

Paperclip::Attachment.default_options[:path] = ':rails_root/public/system/attachments/:id/:basename:style.:extension'
Paperclip::Attachment.default_options[:use_timestamp] = false
Paperclip::HttpUrlProxyAdapter.register
