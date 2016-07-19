# encoding: UTF-8
class Scenodico
  class << self

    # Pour REST
    def get mid
      mid = mid.to_i
      @instances      ||= {}
      @instances[mid] ||= Scenodico::Mot.new(mid)
    end

    # +options+
    #   :with_definition      True si on doit charger la définition (defaut: false)
    def list options = nil
      options ||= Hash::new
      options
      data_request = {}
      data_request.merge!(order: "mot ASC")
      colonnes = if options[:as] == :ids
        [:mot] # on charge toujours les mots pour pouvoir les classer
      elsif options.key?(:colonnes)
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
      @mots = @mots.sort_by { |h| h.merge!(letters: h[:mot][0..2].normalize) ; h[:letters] }
      @count = @mots.count

      # Retour en fonction du format :as demandé
      case options[:as] || :data
      when :data      then @mots
      when :id, :ids  then @mots.collect { |h| h[:id] }
      when :instance, :instances
        @mots.collect { |h| Scenodico::Mot::new(h[:id])}
      else
        hmots = {}
        @mots.each { |h| hmots.merge! h[:id] => h }
        hmots
      end
    end

    # {Fixnum} Le nombre de mots
    def count ; @count ||= table_mots.count end

  end #/<<self
end #/Filmodico
