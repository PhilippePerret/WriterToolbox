# encoding: UTF-8
class Forum
class Sujet

  # ---------------------------------------------------------------------
  #   Instances Forum::Sujet (un sujet en particulier)
  # ---------------------------------------------------------------------

  def as_li
    # return "#{id}"
    (
      as_titre_in_listing_messages  +
      div_infos_last_message        +
      div_infos_sujet               +
      div_tools
    ).in_li(class:'topic')
  end

  def as_titre_in_listing_messages
    "#{name}".in_div(class:'titre')
  end
  def div_infos_last_message
    (
      info_last_message
    ).in_div(class: 'infos')
  end

  # Retourne le dernier message sur le sujet courant
  def last_post
    @last_post ||= forum.posts.list(for:1, as: :instance, sujet_id: id).first
  end
  def pseudo_last_post
    @pseudo_last_post ||= last_post.auteur.pseudo
  end
  def info_last_message
    mess = case last_post
    when nil then "--- aucun dernier message ---"
    else
      last_post.content
    end
    (
      "Dernier message ".in_span(class:'libelle') +
      "(#{last_post.created_at.as_human_date(false)}, de <strong>#{pseudo_last_post}</strong>)".in_span(class:'date') +
      " : #{mess}".in_span
    ).in_a(href:"sujet/#{id}/read?in=forum#post_#{last_post.id}").in_span(class:'last_post')
  end

  def div_infos_sujet
    (
      info_nombre_messages  +
      info_dates_sujet      +
      info_creator
    ).in_div(class:'infos_sujet')
  end
  def info_dates_sujet
    (
      "Sujet créé le ".in_span(class:'libelle') +
      "#{created_at.as_human_date(false)}"
    ).in_span(class:'date')
  end
  def info_creator
    (
      " par ".in_span(class:'libelle') +
      "<strong>#{creator.pseudo}</strong> (#{creator.grade_humain})".in_span
    ).in_span(class:'creator')
  end
  def info_nombre_messages
    (
      "Nombre de messages : ".in_span(class:'libelle') +
      "#{count || 0}".in_span
    ).in_span(class:'count')
  end

  # Les outils pour le sujet, avec des outils différents
  # en fonction du niveau de l'user
  def div_tools
    (
    "Détruire ce sujet".in_a(href:"sujet/#{id}/destroy?in=forum", onclick:"if(confirm('Voulez-vous vraiment détruire ce sujet ?')){return true}else{return false}") +
    '<br />' +
    "Lire ce sujet".in_a(href:"sujet/#{id}/read?in=forum")
    ).in_div(class:'hidetools')
  end

end #/Sujet
end #/Forum
