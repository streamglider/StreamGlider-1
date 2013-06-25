Paperclip::Attachment.default_options.update({
  :path => ":rails_root/public/system/:attachment/:hash.:extension",
  :url => "/system/:attachment/:hash.:extension",
  :hash_secret => "" # TODO: generate your hash secret
})
