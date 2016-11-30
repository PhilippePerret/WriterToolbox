# encoding: UTF-8
class Cnarration
class Page

  def destroy
    if destruction_confirmed?
      # On prend l'identifiant du livre pour rediriger vers
      # la table des matières du livre après la destruction de la page
      bookid = livre_id.to_i
      # === Procéder ===
      proceed_destruction
      # On redirige vers la table des matières du livre de la page ou
      # l'accueil de la collection.
      redirection = bookid > 0 ? "livre/#{bookid}/tdm" : "livre/list"
      redirect_to "#{redirection}?in=cnarration"
    else
      # === Pour la confirmation ===
      preparer_confirmation
    end
  end


  def destruction_confirmed?
    param(:confirmation_destruction_page) == 'on'
  end

  # = main =
  #
  # Méthode principale qui prépare le message de confirmation de la
  # destruction en disant ce qui va être supprimé.
  #
  # Note : pour le moment, on empêche de supprimer une page qui
  # appartient à une table des matières. Si c'est le cas, on propose
  # de la sortir de cette table des matières.
  #
  def preparer_confirmation
    @operations_destruction = Array.new
    !in_tdm? || begin
      flash 'La page appartient à une table des matières. Par mesure de sécurité, il faut la sortir de cette table des matières avant de pouvoir procéder à sa destruction.'
      return
    end

    @operations_destruction << 'Destruction définitive de la donnée dans la base de données.'

    # Si c'est vraiment une page, on a des fichiers à détruire
    if page?
      if path.exist?
        @operations_destruction << 'Destruction de la page markdown originale.'
      end
      if path_semidyn.exist?
        @operations_destruction << 'Destruction de la page semi-dynamique (ERB)'
      end
    end

    opes =
      @operations_destruction.collect do |ope|
        ope.in_li
      end.join.in_ul
    href = "page/#{id}/edit?in=cnarration&operation=kill_page&confirmation_destruction_page=on"
    btn_proceed = "Procéder à la destruction".in_a(href: href, class: 'btn warning').in_div(class: 'right air')
    flash "La destruction de cette page va comprendre :#{opes}#{btn_proceed}"
  end

  # = main =
  #
  # Méthode qui se charge de la destruction proprement dite de la
  # page Narration.
  #
  def proceed_destruction
    @operations = Array.new

    # Cas spécial, rencontré lors de la tentative de destruction
    # de certaines pages, ou `livre_folder` ne semblait pas être
    # défini. On regarde si ça vient de `livre_id`
    begin
      livre_id || raise('La page ne définit pas son `livre_id`')
      livre_folder || raise('Impossible de définir le livre_folder de la page')
    rescue Exception => e
      debug e
      error e.message
      return
    end

    # Destruction de la page rédigée
    path.exist? && begin
      path.remove
      @operations << 'Destruction de la page markdown originale.'
    end

    # Destruction éventuelle du backup de la page rédigée
    path_backup = SuperFile.new("#{path}.backup")
    path_backup.exist? && begin
      path_backup.remove
      @operations << 'Destruction du backup de la page markdown originale.'
    end

    # Destruction de la page semi-dynamique si elle existe.
    path_semidyn.exist? && begin
      path_semidyn.remove
      @operations << 'Destruction de la page semi-dynamique ERB.'
    end
    flash "Destruction opérée avec succès (#{@operations.pretty_join})."

    # On doit terminer par la destruction de la donnée dans la
    # table, sinon, les paths ne pourraient pas être déterminés.
    Cnarration.table_pages.delete(id)
    @operations << 'Destruction de la donnée dans la table.'

  rescue Exception => e
    debug e
    error "Problème en procédant à la destruction : #{e.message}."
  end


  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  # Retourne true si la page appartient à une table des matières
  #
  # Rappel : en temps normal, la page appartient à un livre (livre_id),
  # mais elle peut être dans ou hors de la table des matières du livre.
  def in_tdm?
    @is_in_tdm === nil && @is_in_tdm = livre.tdm.pages_ids.include?(id)
    @is_in_tdm
  end

end #/Page
end #/Cnarration
