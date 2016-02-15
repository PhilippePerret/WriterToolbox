# encoding: UTF-8
class Scenodico
  class << self

    # Pour REST
    def get mid
      mid = mid.to_i
      @instances ||= Hash::new
      @instances[mid] ||= Scenodico::Mot::new(mid)
    end

    # +options+
    #   :with_definition      True si on doit charger la définition (defaut: false)
    def list options = nil
      options ||= Hash::new
      options
      data_request = Hash::new
      data_request.merge!(order: "mot ASC")
      colonnes = if options[:as] == :ids
        [:mots] # on charge toujours les mots pour pouvoir les classer
      elsif options.has_key?(:colonnes)
        options.delete(:colonnes)
      else
        [:mot, :synonymes, :contraires, :relatifs, :type_def]
      end
      colonnes << :definition if options[:with_definition]
      data_request.merge!(colonnes: colonnes)
      @mots = table_mots.select(data_request)

      # Dans la table, le `order by mot` ne tient pas compte des caractères
      # accentués et les envoie vers la fin les mots commençant par des
      # accents et des diacritiques. Il faut donc classer ici les mots
      @mots = @mots.sort_by { |mid, h| h.merge!(letters: h[:mot][0..2].normalize) ; h[:letters] }
      @count = @mots.count
      
      # Retour en fonction du format :as demandé
      case options[:as] || :data
      when :data      then @mots.collect { |mid,h| h }
      when :id, :ids  then @mots.collect { |mid,h| mid }
      when :instance, :instances
        @mots.collect { |mid,h| Scenodico::Mot::new(mid)}
      else
        @mots
      end
    end

    # {Fixnum} Le nombre de mots
    def count
      @count ||= list(as: :ids).count
    end

  end #/<<self
end #/Filmodico
