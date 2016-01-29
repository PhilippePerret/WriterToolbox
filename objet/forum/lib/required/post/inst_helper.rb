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
      content_formated +
      boutons_inter
    ).in_div(class:'content')
  end

  # Traitement du contenu du message
  def content_formated
    content.gsub!(/\[cite([0-9]+)\](.*)\[\/cite\1\]/){
      post_id   = $1.to_i
      citation  = $2.to_s
      post_cite = Forum::Post::get(post_id)
      "<div class='citation'>"+
        "<span class='auteur-citation'>#{post_cite.auteur.pseudo}</span>" +
        "#{citation}" +
        "<span class='link-citation'><a href='post/#{post_id}/read?in=forum'>Lire l'original</a></span>" +
      "</div>"
    }
    content.to_html
  end
  def post_infos
    @post_infos ||= begin
      (
        updated_at.as_human_date(true).in_span(class: 'date') +
        "##{numero}".in_span(class:'numero')
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

  def boutons_inter
    (
      bouton_editer     +
      bouton_supprimer  +
      bouton_repondre   +
      bouton_votes
    ).in_div(class:'btns')
  end

  def bouton_editer
    return "" unless current_user_is_owner? || user.grade > 6
    "Modifier".in_a(href:"post/#{id}/edit?in=forum")
  end
  def bouton_repondre
    return "" unless user.grade > 2
    "Répondre".in_a(href:"post/#{id}/answer?in=forum")
  end
  def bouton_supprimer
    return "" unless user.grade > 6
    "Détruire".in_a(href:"post/#{id}/destroy?in=forum", style:'background-color:red;color:white', onclick:"if(confirm('Voulez-vous réellement détruire définitivement ce message ?')){return true}else{return false}")
  end
  def bouton_votes
    return "" unless user.grade > 1
    "+1".in_a(href:"post/#{id}/vote?in=forum&v=1", class:'vote', title:"“Upvotez” pour ce message si vous l'avez apprécié ou que vous le trouvez intéressant ou pertinent.") +
    "-1".in_a(href:"post/#{id}/vote?in=forum&v=-1", class:'vote', title:"“Downvotez” pour ce message s'il ne présente pas d'intérêt pour vous.")
  end
end #/Post
end #/Forum
