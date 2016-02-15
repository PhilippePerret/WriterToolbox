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
        []
      elsif options.has_key?(:colonnes)
        options.delete(:colonnes)
      else
        [:mot, :synonymes, :contraires, :relatifs, :type_def]
      end
      colonnes << :definition if options[:with_definition]
      data_request.merge!(colonnes: colonnes)
      @mots = table_mots.select(data_request)

      case options[:as] || :data
      when :data then @mots.values
      when :id, :ids  then @mots.keys
      when :instance, :instances
        @mots.keys.collect{|mid| Scenodico::Mot::new(mid)}
      else @mots
      end
    end
  end #/<<self
end #/Filmodico
