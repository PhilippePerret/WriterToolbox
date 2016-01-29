# encoding: UTF-8
post = site.objet

flash "Message ##{post.id} [PAS ENCORE] détruit (cf. post/destroy.rb)"

redirect_to :last_route
