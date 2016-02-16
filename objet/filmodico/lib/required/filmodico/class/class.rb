# encoding: UTF-8
=begin
Class Filmodico
=end
class Filmodico
  class << self

    # Retourne l'objet Filmodico de référence +film_ref+ qui peut
    # être soit l'ID (Fixnum) soit le FILM_ID (String)
    def get film_ref
      @instances ||= Hash::new
      @instances[film_ref] ||= new(film_ref)
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
      elsif options.has_key?(:colonnes)
        options.delete(:colonnes)
      else
        [:titre, :titre_fr, :annee, :realisateur]
      end
      colonnes << :resume if options[:with_resume]
      data_request.merge!(colonnes: colonnes)
      @films = table_films.select(data_request)

      # Dans la table, le `order by mot` ne tient pas compte des caractères
      # accentués et les envoie vers la fin les mots commençant par des
      # accents et des diacritiques. Il faut donc classer ici les mots
      @films = @films.sort_by { |fid, h| h.merge!(letters: h[:titre][0..2].normalize) ; h[:letters] }
      @count = @films.count

      # Retour en fonction du format :as demandé
      case options[:as] || :data
      when :data      then @films.collect { |fid,h| h }
      when :id, :ids  then @films.collect { |fid,h| fid }
      when :instance, :instances
        @films.collect { |fid,h| Filmodico::new(fid)}
      else
        @films
      end
    end

    def count
      @count ||= list(as: :ids).count
    end

    def table_films
      @table_films ||= site.db.create_table_if_needed('filmodico', 'films')
    end

  end #/<<self
end #/Filmodico
