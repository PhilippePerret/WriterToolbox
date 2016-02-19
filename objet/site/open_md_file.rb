# encoding: UTF-8
=begin
  Utilisé pour ouvrir un fichier Markdow
=end

flash "Ouverture de #{param :path}"

`open "#{param :path}"`


redirect_to :last_route
