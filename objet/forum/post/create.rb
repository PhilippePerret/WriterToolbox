# encoding: UTF-8

def sujet
  @sujet ||= Forum::Sujet::get(param(:sid).to_i)
end

# On crée le message avant de passer à la vue d'édition
post = Forum::Post::new
post.sujet_id = param(:sid)
post.bit_validation = user.grade > 3 ? 1 : 0
post.create

( sujet.add_post post )
( user.add_post post  )


redirect_to "post/#{post.id}/edit?in=forum"
