# encoding: UTF-8
raise_unless_identified

def sujet
  @sujet ||= site.objet
end

if sujet.followed_by?(user.id)
  # On retire ce suiveur du sujet
  sujet.remove_follower(user.id)
  flash "Vous ne suivez plus le sujet “#{sujet.name}”."
else
  error "Vous ne suivez pas ce sujet, vous ne pouvez donc pas ne plus le suivre, voyons…"
end

redirect_to :last_route
