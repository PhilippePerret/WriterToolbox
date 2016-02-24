# encoding: UTF-8

# Rappel : Forum est un singleton
class Forum

  # = main =
  #
  # Retourne une liste des messages à valider
  #
  def ul_messages_a_valider
    if new_messages.count == 0
      "Aucun nouveau message à valider".in_li
    else
      new_messages.collect{ |imessage| imessage.as_li }.join
    end.in_ul(id:"messagesavalider")
  end

  # = main =
  #
  # Retourne une liste des sujets nouveaux à valider
  #
  def ul_sujets_a_valider
    if new_sujets.count == 0
      "Aucun sujet et aucune question à valider.".in_li
    else
      new_sujets.collect { |isujet| isujet.as_li }.join
    end.in_ul(id:"sujetsavalider")
  end

  # ---------------------------------------------------------------------
  #   Sous-méthodes
  # ---------------------------------------------------------------------

  # Retourne la liste des instances de nouveaux sujets
  def new_sujets
    @new_sujets ||= begin
      Forum::table_sujets.select(where:"options LIKE '0%'", order:"created_at ASC", colonnes:[]).keys.collect do |sid|
        Forum::Sujet::get(sid)
      end
    end
  end

  # Retourne la liste des instances de nouveaux messages
  def new_messages
    @new_messages ||= begin
      Forum::table_posts.select(where:"options LIKE '0%'").keys.collect do |mid|
        Forum::Post::get(mid)
      end
    end
  end
end #/Forum

class Forum
class Sujet
  def as_li
    (
      (
        name.in_span(class:'titre') +
        creator.pseudo.in_span(class:'auteur')
      ).in_div(class:'specs') +
      boutons_edition
    ).in_li(class:'item')
  end

  def boutons_edition
    (
      "VALIDER".in_a(href:"sujet/#{id}/valider?in=forum", class:'btn small') +
      "REFUSER…".in_a(href:"sujet/#{id}/refuser?in=forum", class:'btn warning small')
    ).in_div(class:'edition')
  end
end #/Sujet

# ---------------------------------------------------------------------
#   Forum::Post
# ---------------------------------------------------------------------
class Post
  def as_li
    (
      specifications  .in_div(class:'specs') +
      boutons_edition .in_div(class:'edition')
    ).in_li(class:'item')
  end
  def specifications
    content_formated.in_span(class:'content') +
    auteur.pseudo.in_span(class:'auteur')
  end
  def boutons_edition
    "VALIDER".in_a(href:"post/#{id}/valider?in=forum", class:'btn small') +
    "REFUSER…".in_a(href:"post/#{id}/refuser?in=forum", class:'btn warning small')
  end
end #/Post

end #/Forum
