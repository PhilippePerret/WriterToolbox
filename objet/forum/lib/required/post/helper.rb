# encoding: UTF-8
=begin
Extension de Forum::Message pour la gestion des messages
=end
class Forum
class Post

  # Le post, pour une liste de messages, comme par exemple les
  # derniers messages envoyés ou les derniers dans chaque sujet.
  def as_li
    (
      sujet.name.in_span('name')  +
      auteur.pseudo.in_span('pseudo') +
      updated_at.as_human_date(true).in_span('date')
    ).in_li(class:'post', id:"post-#{id}")
  end
end
end
