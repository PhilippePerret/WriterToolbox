# encoding: UTF-8
class User
class << self

  # RETURN Une liste à fournir à as_select, contenant en premier
  # élément l'ID de l'user et en deuxième son pseudo.
  #
  # +options+ peut définir :
  #   :actif
  #   :inactif
  #   :en_attente
  #   :en_pause
  #   :detruit
  #
  def values_select options = nil
    options ||= Hash.new

    drequest = {
      order:    'LOWER(pseudo) ASC',
      colonnes: [:pseudo]
    }

    template_pseudo = user.admin? ? "%{pseudo} (#%{id})" : "%{pseudo}"

    # Faire la liste et la retourner
    User.table_users.select(drequest).collect do |huser|
      [huser[:id], (template_pseudo % {pseudo: huser[:pseudo].capitalize, id: huser[:id]})]
    end
  end

end #/<< self
end #/User
