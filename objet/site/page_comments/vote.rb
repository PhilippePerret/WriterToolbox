# encoding: UTF-8
=begin

  Ce module ne doit être atteint que par ajax

=end
class Page
  class Comments
    def add_vote sens
      prop = sens == 'up' ? :votes_up : :votes_down
      current_value = get(prop)
      new_value = current_value + 1
      set(prop => new_value)
      new_value
    end
  end #/Comments
end #/Page

if user.identified?
  pcom_id = site.current_route.objet_id
  retour = Page::Comments.new(pcom_id).add_vote(param(:vote))
  Ajax << {vote_ok: true, votes_newvalue: retour}
  flash "Merci #{user.pseudo} pour votre vote."
else
  Ajax << {vote_ok: false}
  error 'Désolé, seuls les visiteurs inscrits peuvent voter.'
end
