# encoding: UTF-8
=begin
Extension de Forum::Message pour la gestion des messages
=end
class Forum
class Post

  attr_reader :numero

  # Pour tous les messages
  # Quand c'est un administrateur, l'ID est ajouté.
  # Par exemple "Message #32 enregistré" versus "Message enregistré"
  def chose
    @chose ||= "Message #{user.admin? ? id : ''}"
  end


  # Le post, pour une liste de messages, comme par exemple les
  # derniers messages envoyés ou les derniers dans chaque sujet.
  #
  # Note : Pour obtenir la même apparence partout, mettre le
  # code de retour dans <ul id="posts"> même si c'est un seul
  # message qui doit être affiché.
  # Note : Mettre aussi dans les params as: :full_message pour
  # avoir l'intégralité des données.
  #
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
    debug "-> as_li avec full_message = #{full_message.inspect}"
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
    @content_formated ||= begin
      str = "#{content}"
      str.gsub!(/\[cite([0-9]+)\](.*)\[\/cite\1\]/){
        post_id   = $1.to_i
        citation  = $2.to_s
        post_cite = Forum::Post::get(post_id)
        "<div class='citation'>"+
          "<span class='auteur-citation'>#{post_cite.auteur.pseudo}</span>" +
          "#{citation}" +
          "<span class='link-citation'><a href='post/#{post_id}/read?in=forum'>Lire l'original</a></span>" +
        "</div>"
      }
      str.gsub!(/\[url="(.*?)"\](.*?)\[\/url\]/){
        url   = $1.freeze
        titre = $2.freeze
        titre.in_a(href: url)
      }
      str.gsub!(/\[(i|u|b|strong|em)\](.*?)\[\/\1\]/){
        tag   = $1
        inner = $2
        "<#{tag}>#{inner}</#{tag}>"
      }
      str.split("\n").reject{|p|p.empty?}.collect{|p| p.in_p}.join
    end
  end


  def post_infos
    @post_infos ||= begin
      (
        ("Votes".in_span(class:'libelle') + vote.to_s.in_span).in_span(class:'votes') +
        ("Créé le".in_span(class:'libelle') + updated_at.as_human_date(true)).in_span(class: 'date') +
        "Index".in_span(class:'libelle') + ("##{numero}").in_span(class:'numero')
      ).in_div(class:'infos_post')
    end
  end
  def auteur_infos
    (
      auteur.pseudo.in_span(class: 'pseudo')   +
      ("Messages : ".in_span(class:'libelle')  + auteur.posts_count.to_s).in_span(class: 'nbposts') +
      ("Depuis le : ".in_span(class:'libelle') + auteur.created_at.as_human_date(false)).in_span(class:'date') +
      ("Grade : ".in_span(class:'libelle')     + auteur.grade_humain).in_span(class:'grade')
    ).in_div(class:'infos_auteur')

  end

  def boutons_inter
    (
      mark_last_update  +
      bouton_editer     +
      bouton_supprimer  +
      bouton_repondre   +
      bouton_votes
    ).in_div(class:'btns')
  end

  # Retourne le texte indiquant que le message a été modifié, peut-être
  # par quelqu'un d'autre.
  # Noter qu'il ne suffit pas de comparer l'exactitude entre created_at
  # et updated_at, entendu qu'il peut y avoir un décalage "naturel", puisqu'en
  # utilisant le bouton général "Répondre" (pas celui d'un message), on crée
  # le message avant de l'enregistrer. Donc on indique la modification que
  # si elle a eu lieu au moins deux heures après la création.
  def mark_last_update
    return "" unless updated_at > (created_at + 2*3600) || modified_by != nil
    mlu = String::new
    mlu << "modifié le #{updated_at.as_human_date}"
    mlu << " par <strong>#{User::get(modified_by).pseudo}</strong>" unless modified_by.nil?
    mlu.in_span(class:'lastupdate fleft tiny')
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
    return "" if (user.grade < 2) || user.id == user_id
    "+1".in_a(href:"post/#{id}/vote?in=forum&v=1", class:'vote', title:"“Upvotez” pour ce message si vous l'avez apprécié ou que vous le trouvez intéressant ou pertinent.") +
    "-1".in_a(href:"post/#{id}/vote?in=forum&v=-1", class:'vote', title:"“Downvotez” pour ce message s'il ne présente pas d'intérêt pour vous.")
  end
end #/Post
end #/Forum
