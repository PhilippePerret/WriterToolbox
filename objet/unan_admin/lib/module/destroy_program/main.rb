# encoding: UTF-8
#
# Module de destruction complète d'un programme.
#
# Attention, contrairement à la procédure d'arrêt forcée qui
# peut être initiée par l'auteur, ici, c'est une véritable destruction
# de toutes les données concernant le programme qui est opérée. En
# toute logique, le paiement doit avoir été remboursé.
#

# Il faut fournir en paramètre :
#   - program_to_destroy_id     ID du programme à détruire
#   - program_invoice           Le numéro de facture (pour ne pas faire n'importe quoi)
#   - program_auteur_id         Optionnellement, l'ID de l'auteur du programme

# Il faut bien évidemment être administrateur pour procéder à cette
# opération, être même grand manitou
raise_unless user.manitou?

class UProgram

    # RETURN true pour faire une simple simulation, c'est-à-dire ne
    # pas détruire vraiment le programme.
    #
    # Noter que ça accomplit quand même toutes les actions, mais ça
    # remet les données en place.
    def simulation?
        false
    end

    attr_reader :id
    attr_reader :auteur_id
    attr_reader :invoice
    attr_reader :report

    # Instanciation
    #
    # +id+ L'identifiant du programme à détruire. Noter que si l'invoice
    #      est fournie, id peut être nil (ce qui arrive quand on a déjà
    #      procédé au début de la destruction)
    # +invoice+ Numéro de facture pour le paiement de ce programme
    # +auteur_id+   Il faut fournir l'identifiant de l'auteur lorsque le
    #               programme a été détruit. Cela se produit lorsque l'on
    #               est arrivé presque au bout du travail mais qu'il reste
    #               le paiement à détruire.
    def initialize id, invoice, auteur_id = nil
        @id = id
        @id.nil? || @id = @id.to_i
        @invoice = invoice.nil_if_empty
        @auteur_id = auteur_id.nil_if_empty
        @auteur_id.nil? || @auteur_id = @auteur_id.to_i
        @invoice != nil || raise('Pour détruire un programme, il faut absolument fournir son numéro de facture qui sert de confirmation.')
        @report = Array.new
    end

    # = main =
    #
    # Méthode principale qui détruit entièrement le programme et
    # tout ce qui le concerne, sauf l'auteur, qui doit être détruit
    # avec une autre procédure le cas échéant
    #
    # Noter que la méthode peut s'y reprendre en plusieurs fois
    # RETURN Le code HTML du rapport d'opération (note : le même rapport
    # a été mis dans le débug, mais au format :plain)
    #
    def destroy_all
        confirme_destruction    || return
        @report << 'Confirmation de la destruction OK'
        # Détruire la rangée du projet dans la table
        destroy_projet          || return
        @report << 'Destruction du projet OK'
        # Détruire les tables de l'auteur dans :users_tables
        destroy_tables_auteur   || return
        @report << 'Destruction des tables de l’auteur OK'
        # Détruire la rangée du programme dans la table
        destroy_program         || return
        @report << 'Destruction du programme de l’auteur OK'
        # Détruire le paiement
        destroy_paiement        || return
        @report << 'Destruction du paiement OK'
        debug report_formated(:plain)
        report_formated(:html)
    end

    # Rapport final, pour affichage, en fonction du format voulu, qui
    # peut être :html (les retours sont br) ou :plain (les retours chariot
    # sont de vrais retours chariot
    def report_formated format = :plain
        case format
        when :plain then @report.join("\n")
        when :html  then @report.join('<br />')
        end
    end


    # Méthode confirmant la destruction, si le numéro de facture
    # est conforme à celui enregistré.
    #
    # Retourne TRUE si c'est OK ou FALSE dans le cas contraire
    #
    def confirme_destruction
        User.table_paiements.select(where: {user_id: auteur.id}).each do |hpaiement|
            return true if hpaiement[:facture] == @invoice
        end
        error 'Impossible de trouver un paiement correspondant au numéro de facture fourni.'
        return false
    end

    # Destruction de la rangée du programme dans la table
    def destroy_program
        count_init = Unan.table_programs.count
        simulation? && hprogramme = Unan.table_programs.get(program.id)
        Unan.table_programs.delete(program.id)
        if Unan.table_programs.count == count_init - 1
            # Si c'est une simulation, on remet les données dans la
            # table
            simulation? && Unan.table_programs.insert(hprogramme)
            true
        else
            error 'Le programme ne semble pas avoir été détruit. Je m’arrête ici.'
        end
    end

    # Destruction du projet
    def destroy_projet
        count_init = Unan.table_projets.count
        simulation? && hprojet = Unan.table_projets.get(projet.id)
        Unan.table_projets.delete(projet.id)
        if Unan.table_projets.count == count_init - 1
            simulation? && Unan.table_projets.insert(hprojet)
            true
        else
            error 'Le projet ne semble pas avoir été détruit. Je m’arrête ici.'
        end
    end

    # Destruction de toutes les tables de l'user dans :users_tables
    #
    # Il ne faut détruire les tables de l'auteur que s'il n'a suivi
    # qu'un seul programme. Dans le cas contraire, il ne faut détruire que
    # les enregistrement qui concerne le projet à détruire.
    #
    def destroy_tables_auteur
        ['works', 'pages_cours', 'quiz'].each do |ktable|
            table_name = "unan_#{ktable}_#{auteur.id}"
            tbl = site.dbm_table(:users_tables, table_name)
            tbl.exist? || next
            if un_seul_programme?
                if simulation?
                    # Ici, c'est trop compliqué de simuler, donc on va faire
                    # comme ça
                else
                  tbl.drop
                  if tbl.exist?
                      error "La table auteur #{table_name} n'a pas pu être détruite. Je dois renoncer."
                      return false
                  end
                end
            else
                # Si l'auteur possède plusieurs programmes, on ne doit détruire
                # que les données qui correspondent au programme à détruire
                @report << 'L’auteur possède plusieurs programmes. Destruction des données de ce programme seulement.'
                tbl.delete(where: {program_id: program.id}) unless simulation?
            end
        end
    end

    # Destruction finale du paiement
    #
    # Note : ça doit être absolument la dernière donnée détruite
    # car le numéro de facture permet de confirmer la destruction
    def destroy_paiement
        count_init = User.table_paiements.count
        simulation? && hpaiement = User.table_paiements.get(where: {facture: invoice})
        User.table_paiements.delete(where: {facture: invoice})
        if User.table_paiements.count == count_init - 1
            simulation? && User.table_paiements.insert(hpaiement)
            true
        else
            error 'Apparemment, le paiement n’a pas pu être détruit…'
        end
    end


    # ----------------------------------------------------------
    # Data utiles
    # ----------------------------------------------------------

    # Méthode qui renvoie TRUE si l'auteur ne possède qu'un seul programme
    # et FALSE dans le cas contraire.
    # Pour le moment, cela ne sert qu'à savoir si on doit détruire les tables
    # :users_tables de l'auteur ou seulement les données qui correspondent au
    # programme à détruire
    def un_seul_programme?
        Unan.table_programs.count(where: {auteur_id: auteur.id}) == 1
    end

    # L'auteur du programme (instance {User})
    def auteur
        @auteur ||= begin
                        if auteur_id != nil
                            User.new(auteur_id)
                        elsif id != nil
                            User.new(program.auteur_id)
                        else
                            raise 'Impossible de récupérer l’auteur. Il faut soit préciser l’identifiant du programme soit l’identifiant de l’auteur.'
                        end
                    end
    end
    def program
        @program ||= begin
                         if id.nil?
                             nil
                         else
                             Unan::Program.new(id)
                         end
                     end
    end
    def projet
        @projet ||= begin
                        if program == nil
                            pid = Unan.table_projets.get(where: {auteur_id: auteur.id})
                        else
                            Unan::Projet.new(program.projet_id)
                        end
                    end
    end
end
p = UProgram.new(param(:program_to_destroy_id), param(:program_invoice), param(:program_auteur_id))
p.destroy_all
