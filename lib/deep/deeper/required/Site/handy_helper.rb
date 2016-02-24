# encoding: UTF-8

# +path+ depuis le dossier ./view/img
def image path, options = nil
  options ||= Hash::new
  path = (site.folder_images + path).to_s
  path.in_image(options)
end
