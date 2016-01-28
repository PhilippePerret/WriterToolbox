# encoding: UTF-8
=begin
Extension de Forum::Message pour la gestion des messages
=end
class Forum
class Post

  attr_reader :numero

  # Le post, pour une liste de messages, comme par exemple les
  # derniers messages envoyés ou les derniers dans chaque sujet.
  # +params+
  #   :as       :full     Comme un message complet
  #             :titre    (défaut) Comme un titre pour un listing
  #
  def as_li params = nil
    params ||= Hash::new
    @numero       = params.delete(:numero)
    return_as     = params.delete(:as)
    full_message  = return_as == :full_message

    li = ""
    li << post_infos
    li << auteur_infos if full_message
    li << post_content if full_message
    li << "".in_div(style:'clear:both')
    # Code retourné
    li.in_li(class:'post', id:"post_#{id}")
  end

  def post_content
    (
      content +
      boutons_inter
    ).in_div(class:'content')
  end
  def boutons_inter
    (
      "Éditer".in_a()     +
      "Répondre".in_a()   +
      "Supprimer".in_a()
    ).in_div(class:'btns')
  end
  def post_infos
    @post_infos ||= begin
      (
        "Message ##{numero}".in_span(class:'numero') +
        updated_at.as_human_date(true).in_span(class: 'date')
      ).in_div(class:'infos_post')
    end
  end
  def auteur_infos
    (
      auteur.pseudo.in_span(class: 'pseudo') +
      ("Messages : ".in_span(class:'libelle') + auteur.posts_count.to_s).in_span(class: 'nbposts') +
      ("Depuis le : ".in_span(class:'libelle') + auteur.created_at.as_human_date(false)).in_span(class:'date') +
      ("Grade : ".in_span(class:'libelle') + auteur.grade_humain).in_span(class:'grade')
    ).in_div(class:'infos_auteur')

  end
end
end
