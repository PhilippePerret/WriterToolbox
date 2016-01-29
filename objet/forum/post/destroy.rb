# encoding: UTF-8
post = site.objet
post.delete
flash "#{post.chose} détruit."

redirect_to :last_route
