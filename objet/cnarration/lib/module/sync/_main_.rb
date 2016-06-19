# encoding: UTF-8
class SynchroNarration
class << self

  # {Array} Liste des messages de suivi, pour la synchro
  # générale.
  attr_reader :suivi

  # ---------------------------------------------------------------------
  #   Méthodes de synchro
  # ---------------------------------------------------------------------

  # Méthode principale qui va synchroniser la propriété `state`
  # des pages locales avec les données du fichier distant si
  # nécessaire
  def synchronise_statuts_of_pages

    table_dis = site.dbm_table(:cnarration, 'narration', online = true)
    table_loc = site.dbm_table(:cnarration, 'narration', online = false)

    # On boucle seulement sur les pages (pas sur les chapitres et
    # sous-chapitres)
    table_dis.select(where: "options LIKE '1%'", colonnes:[:options]).each do |pdata|
      pid = pdata[:id]
      statut_dis_str  = pdata[:options][1]
      statut_dis      = statut_dis_str.to_i(11)
      hpage_loc       = table_loc.get(pid, colonnes:[:options])
      if hpage_loc.nil?
        @suivi << "ERROR : Page locale ##{pid} inexistante…"
        next
      end
      options_loc = hpage_loc[:options]
      statut_loc  = options_loc[1].to_i(11)

      if statut_dis > statut_loc
        opts = options_loc
        opts[1] = statut_dis_str
        table_loc.update(pid, { options: opts })
        @suivi << "Statut page ##{pid} monté de #{statut_loc} à #{statut_dis} en local"
      elsif statut_loc > statut_dis
        opts = pdata[:options]
        opts[1] = statut_loc.to_s
        table_dis.update(pid, { options: opts } )
        @suivi << "Statut page ##{pid} monté de #{statut_dis} à #{statut_loc} en distant"
      else
        # => OK
      end

    end # fin de boucle sur toutes les pages distantes
  end

end #/<<self
end #/SynchroNarration
