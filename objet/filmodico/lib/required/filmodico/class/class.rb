# encoding: UTF-8
=begin
Class Filmodico
=end
class Filmodico
  extend MethodesMainObjets
  class << self

    # Retourne l'objet Filmodico de référence +film_ref+ qui peut
    # être soit l'ID (Fixnum) soit le FILM_ID (String)
    def get film_ref
      @instances            ||= {}
      @instances[film_ref]  ||= new(film_ref)
    end


    # +options+
    #   :with_resume      Si true, on remonte aussi le résumé dans les données
    def list options = nil
      options ||= Hash::new
      options
      data_request = Hash::new
      data_request.merge!(order: "titre ASC")
      colonnes = if options[:as] == :ids
        [:titre] # on charge toujours les titres pour pouvoir les classer
      elsif options.key?(:colonnes)
        options.delete(:colonnes)
      else
        [:titre, :titre_fr, :annee, :realisateur]
      end
      colonnes << :resume if options[:with_resume]
      data_request.merge!(colonnes: colonnes)
      @films = table_filmodico.select(data_request)

      # Dans la table, le `order by mot` ne tient pas compte des caractères
      # accentués et les envoie vers la fin les mots commençant par des
      # accents et des diacritiques. Il faut donc classer ici les mots
      @films = @films.sort_by { |h| h.merge!(letters: h[:titre].force_encoding('utf-8')[0..2].normalize) ; h[:letters] }
      @count = @films.count

      # Retour en fonction du format :as demandé
      case options[:as] || :data
      when :data      then @films.collect { |h| h }
      when :id, :ids  then @films.collect { |h| h[:id] }
      when :instance, :instances
        @films.collect { |h| Filmodico::new(h[:id])}
      else
        @films
      end
    end

    def count
      @count ||= list(as: :ids).count
    end

    # Affiche la liste des films du filmodico pour
    # la console (et seulement par et pour la console).
    # Répond à `list films` ou `affiche table films`
    def films_in_table
      flash "Attention, cette liste de films est celle du Filmodico, PAS CELLE qui sert pour l'outil Analyse de films, même si les deux listes sont synchronisées."
      console.show_table self.table_filmodico
      "OK"
    rescue Exception => e
      debug e
      "# ERROR: #{e.message}"
    end


    def table_filmodico
      @table_filmodico ||= site.dbm_table(:biblio, 'filmodico')
    end

    # -> MYSQL ANALYSE
    def table_films_analyse
      @table_films_analyse ||= site.db.create_table_if_needed('analyse', 'films')
    end

  end #/<<self
end #/Filmodico
