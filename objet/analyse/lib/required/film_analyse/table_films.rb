# encoding: UTF-8
=begin
Extension de FilmAnalyse pour les commandes de console
=end
class FilmAnalyse
  class << self

    # {BdD::Table} La table contenant les informations minimales sur
    # les films.
    # -> MYSQL ANALYSE
    def table_films
      @table_films ||= site.db.create_table_if_needed('analyse', 'films')
    end

    # {SiteHtml::DBM_TABLE} La table contenant les films du Filmodico
    def table_filmodico
      @table_filmodico ||= site.dbm_table(:biblio, 'filmodico')
    end

    # Affiche la liste des films dans la table analyse.films, pour
    # la console (et seulement par et pour la console).
    # Répond à `list films` ou `affiche table films`
    def films_in_table
      flash "Attention, cette liste de films, qui sert pour l'outil Analyse de films, n'est pas à confondre avec les films du Filmodico, même si les deux listes sont synchronisées."
      console.sub_log("Voir l'aide Films & Analyse pour modifier des valeurs.")
      console.show_table self.table_films
      "OK"
    rescue Exception => e
      debug e
      "# ERROR: #{e.message}"
    end


    # Crée un film dans la table analyse.films. C'est la méthode qui était
    # utilisée par la console avec la commande `create film`, mais maintenant
    # il faut empêcher ce comportement : on doit passer par le filmodico
    def create_film dfilm
      error "On ne doit plus utiliser la méthode `create film` pour créer un film analysé. On doit passer par le Filmodico en créant le film et ensuite il sera automatiquement ajouté aux analyses."
      "ERROR"
    end


    # Actualise les données d'un film existant
    # Méthode utilisée par la console, mais maintenant il vaut mieux
    # passer par le tableau de bord d'administration
    def update_film film_ref, dfilm
      if dfilm.has_key?(:options)
        error "Pour modifier les options, il faut utiliser le tableau de bord des analyses."
        "ERROR"
      else
        if film_ref.instance_of?(String)
          hfilm = table_films.select(colonnes:[:options], where:"sym = '#{film_ref}'").values.first
          film_ref = hfilm[:id]
        else
          hfilm = table_films.get(film_ref, colonnes:[])
        end

        dfilm.merge!(updated_at: NOW)

        table_films.update(film_ref, dfilm)
        # Pour vérifier, on ré-affiche toujours la liste des films
        # (en tout cas tant qu'il n'y en a pas trop…)
        films_in_table
      end
    end


  end # << self
end #/FilmAnalyse
