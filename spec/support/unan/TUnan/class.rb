# encoding: UTF-8
class TUnan
  DUSER = {
    pseudo: "InscriteUNAN", # pas de chiffres !
    patronyme: "Inscrite UnanunScript",
    mail: "boa.inscrite.unan@gmail.com",
    password: 'unessaidesignupunan'
  }
  class << self

    # Resetter complètement Inscrite pour qu'elle se
    # retrouve au jour x avec tous les travaux exécutés
    def reset_inscrite xday = 1
      # On récupère son Identifiant dans la table des users.
      # s'il n'existe pas, c'est qu'elle n'existe plus
      id = User.table_users.get(where: "mail = '#{DUSER[:mail]}'")
      if id.nil?
        raise "Il faut recommencer le test qui crée inscrite"
      end
      id = id[:id]
      ins = User.new(id)

      # ---------------------------------------------------------------------
      #   DESTRUCTION
      # ---------------------------------------------------------------------
      created_at = Time.now.to_i - xday * (24 * 3600)

      # On actualise son paiement pour qu'il corresponde au
      # jour voulu
      User.table_paiements.update({where: {user_id: id}}, {created_at: created_at})
      # On détruit son programs
      table_programs = site.dbm_table(:unan, 'programs')
      table_projets = site.dbm_table(:unan, 'projets')

      table_programs.update( {where: {auteur_id: id}}, {
        created_at:   created_at,
        updated_at:   created_at,
        current_pday: xday,
        current_pday_start: NOW - (xday - 1) * 24 * 3600,
        points:       0
        })
      table_projets.update({where: {auteur_id: id}}, {created_at: created_at, updated_at: created_at} )

      # On détruit toutes ses tables Unan (variables et autres)
      ['pages_cours', 'quiz', 'works'].each do |tbl_key|
        table_name = "unan_#{tbl_key}_#{id}"
        tbl = SiteHtml::DBM_TABLE.new(:users_tables, table_name)
        if tbl.exist?
          puts "Table #{table_name} à détruire…"
          tbl.destroy
          puts "OK"
        else
          puts "Table #{table_name} inexistante."
        end
      end

      # Si on ne doit pas partir du premier jour, on marque tous les
      # travaux jusqu'au pday +xday+ accomplis, sauf ceux du jour et
      # de la veille.
      if xday > 1

      end
    end

    def go_and_identify_inscrite
      go_and_identify(DUSER[:mail], DUSER[:password])
    end

    # Retourne une instance de l'inscrite (utilisable seulement
    # à partir du moment où elle est inscrite)
    def inscrite
      @inscrite ||= begin
        id = User.table_users.get(where: "mail = '#{DUSER[:mail]}'")[:id]
        User.new(id)
      end
    end
  end #/<<self
end #/TUnan
