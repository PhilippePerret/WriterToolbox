# encoding: UTF-8
=begin
  Utilisé pour ouvrir un fichier Markdow
=end
flash "Ouverture de #{param :path}"
`open -a #{site.markdown_application} "#{param :path}"`
redirect_to :last_route
