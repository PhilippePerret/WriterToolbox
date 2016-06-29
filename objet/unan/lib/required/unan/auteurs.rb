# encoding: UTF-8
class Unan
class << self

  # LISTE DES AUTEURS DU PROGRAMME
  #
  # +options+
  #     :as     Format des éléments retournés :
  #             :ids    Liste d'identifiant des auteurs (tous)
  #             :instance   Instance d'User
  #             :hash_instances   Instance d'User dans un Hash avec
  #                               en clé l'id de l'auteur
  #
  #     :filtre   Permet de filtrer les auteurs à considérer
  # 
  def auteurs options = nil
    @auteurs_ids ||= begin
      table_programs.select(colonnes: [:auteur_id]).collect do |hprog|
        hprog[:auteur_id]
      end
    end
    options ||= Hash.new
    options.key?(:as) || options.merge!(as: :ids)

    # Un filtre est-il appliqué
    if options.key?(:filtre)

    end

    case options[:as]
    when :ids then @auteurs_ids
    when :instance, :instances
      @auteurs_ids.collect{|uid| User.new(uid)}
    when :hash_instances
      h = Hash.new; @auteurs_ids.each{|uid| h.merge! uid => User.new(uid) }; h
    end
  end

end #/<< self
end #/Unan
