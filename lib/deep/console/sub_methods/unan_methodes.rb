# encoding: UTF-8
raise_unless_admin
class SiteHtml
class Admin
class Console

  def init_unan
    site.require_objet 'unan'
  end

  def detruire_table_pages_cours
    if OFFLINE
      init_unan
      Unan::database.execute("DROP TABLE IF EXISTS 'pages_cours';")
      "Table des pages de cours détruite avec succès."
    else
      "Impossible de détruire la table des pages de cours en ONLINE (trop dangereux)."
    end
  end

  def afficher_table_pages_cours
    init_unan
    show_table Unan::Program::PageCours::table_pages_cours
  end

end #/Console
end #/Admin
end #/SiteHtml
