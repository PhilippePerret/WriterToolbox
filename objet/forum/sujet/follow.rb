# encoding: UTF-8
raise_unless_identified

def sujet
  @sujet ||= site.objet
end

if sujet
  if sujet.followed_by?(user.id)
    error 'Pour information, vous suivez déjà ce sujet.'
  else
    # On ajoute ce suiveur au sujet et réciproquement
    sujet.add_follower(user.id)
    flash "Vous suivez maintenant le sujet “#{sujet.name}”."
  end
end
redirect_to :last_route
