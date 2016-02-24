# encoding: UTF-8
class Forum
class Sujet

  def as_li
    (
      as_titre_in_listing_messages  +
      div_infos_last_message        +
      div_infos_sujet               +
      div_tools
    ).in_li(class:'topic')
  end

  def as_titre_in_listing_messages
    lien_read(name, {class:'inherit'}).in_div(class:'titre')
  end
  def div_infos_last_message
    (
      info_last_message
    ).in_div(class: 'infos')
  end

  # Retourne le dernier message sur le sujet courant
  def last_post
    @last_post ||= begin
      pid = Forum::table_sujets_posts.get(id, colonnes:[:last_post_id])[:last_post_id]
      Forum::Post::get(pid) unless pid.nil?
    end
  end
  def pseudo_last_post
    @pseudo_last_post ||= last_post.auteur.pseudo
  end
  def info_last_message
    return "--- aucun dernier message ---" if last_post.nil? || last_post.created_at.nil?
    # IL faut charger le content du message, qui se trouve dans une
    # autre table
    last_post.content
    mess = if last_post.content.length > 300
      last_post.content_formated.gsub(/<(.*?)>/,'')[0..300] + "[…]"
    else
      last_post.content
    end
    (
      "Dernier message ".in_span(class:'libelle') +
      "(#{last_post.created_at.as_human_date(false)}, de <strong>#{pseudo_last_post}</strong>)".in_span(class:'date') +
      " : #{mess}".in_span
    ).in_a(href:"sujet/#{id}/read?in=forum#post_#{last_post.id}").in_span(class:'last_post')
  end

  # Les outils pour le sujet, avec des outils différents
  # en fonction du niveau de l'user
  def div_tools
    (
      lien_read("Lire ce sujet") +
      lien_edit("Éditer ce sujet") +
      lien_destroy("Détruire ce sujet")
    ).in_div(class:'hidetools')
  end


end #/Sujet
end #/Forum
