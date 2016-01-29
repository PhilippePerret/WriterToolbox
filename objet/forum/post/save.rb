# encoding: UTF-8

def post
  @post ||= site.objet
end

class Forum
class Post

  # Actualisation du message
  def update_post

    # Si celui qui modifie le message est différent de
    # celui qui l'a écrit originellement, on enregistre
    # cette donnée
    modified_by = param(:post)[:modified_by].to_i
    if modified_by != user_id
      modifieur = User::get(modified_by)
      raise "Vous n'êtes pas autorisé à opérer cette modification !" if modifieur.grade < 6
      set( modified_id:modified_by, updated_at:NOW )
    end

    # Si le contenu du message a changé, on enregistre le
    # nouveau contenu.
    contenu = param(:post)[:content].strip
    contenu = contenu.gsub(/\r/,'') if contenu.match(/\n/)
    if contenu != content
      table_content.update(id, { content:contenu, updated_at:NOW } )
    end

    flash "#{chose} enregistré."
  end

end #/Post
end #/Forum


# Actualiser le post et revenir à la place suivante
post.update_post
redirect_to :last_route
