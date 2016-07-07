# encoding: UTF-8
#
# Dans le cron, on ne sert pas de la class User, mais je ne sais même plus pourquoi
# car ce serait possible, en distant.
#
class DUser

    # ID de l'user, l'auteur du programme UN AN UN SCRIPT
    attr_reader :id

    # Pour un auteur du programme UN AN UN SCRIPT
    attr_reader :program_id

    # Comme ces modules sont appelés depuis une méthode (run_procedure), on
    # ne peut pas inclure les modules normalement. Il faut le faire en les
    # étendant de cette façon-là. Et appeler cette méthode en bas de fichier
    # pour être sûr de les initialiser
    def self.init
        include MethodesMySQL 
        site.require_objet 'unan'
        Unan.require_module 'current_pday_user'
        include CurrentPDayClass
    end

    def initialize user_id
        @id = user_id
    end
    def pseudo; @pseudo ||= get(:pseudo)  end
    def mail;   @mail   ||= get(:mail)    end
    def table
        @table ||= User.table_users
    end


    # Pour envoyer un message à l'user
    def send_mail data_mail
        site.send_mail( data_mail.merge(to: self.mail) )
    end

    def current_pday
        @current_pday ||= begin
                              CurrentPDay::new(self)
                          end
    end

    def program
        @program ||= begin
                         Unan::Program.get_current_program_of(id)
                     end
    end
    def program_current_pday; program.current_pday              end
    def program_current_pday_start; program.current_pday_start  end
    def program_rythme; @program_rythme ||= program.rythme      end
    def program_created_at; @program_created_at ||= program.created_at end


    # Méthode qui passe le programme au jour suivant
    def passe_programme_au_jour_suivant
        Unan.table_programs.set(
            program.id, {
            current_pday:       program.current_pday + 1,
            current_pday_start: next_pday_start,
            updated_at:         NOW
        })
        # pour forcer l'actualisation
        @program      = nil
        @current_pday = nil
    end

    # RETURN true si on doit envoyer le rapport à l'auteur
    # On doit l'envoyer si :
    #   - l'auteur veut recevoir ses rapports quotidien
    #   OU - il a de nouveaux travaux ou des travaux en retard
    #   - l'heure de l'envoi est arrivée.
    def send_unan_report?
        if time_to_send_unan_report?
            passe_programme_au_jour_suivant
            return want_daily_mail? || has_new_or_overrun_work?
        else # Non, il n'est pas encore temps
            false
        end
    end

    # ---------------------------------------------------------------------
    # Retourne l'heure du prochain envoi
    def next_pday_start
        @next_pday_start ||= begin
                                 # Pour raccourcir le nom des variables
                                 pday        = program_current_pday
                                 pday_start  = program_current_pday_start
                                 rythme      = program_rythme

                                 # Si l'auteur veut recevoir son mail à heure fixe et qu'il
                                 # est bien en rythme 5, il faut vérifier que l'heure de son
                                 # prochain envoi correspond bien à l'heure qu'il a choisi.
                                 # Dans le cas contraire, il faut modifier l'heure de son
                                 # prochain envoi. Noter que ça peut intervenir à n'importe
                                 # quelle heure.
                                 begin
                                     if fixed_time_mail
                                         if rythme == 5
                                             heure_choisie = heure_envoi_rapport
                                             jour_start    = Time.at(pday_start)
                                             heure_start   = jour_start.hour
                                             if heure_start != heure_choisie
                                                 # L'heure choisie ne correspond pas à l'heure de
                                                 # démarrage du jour-programme courant. On modifie
                                                 # cette heure pour que ça corresponde. C'est-à-dire
                                                 # qu'on prend le jour de démarrage en référence,
                                                 # et qu'on règle le pday_start à l'heure choisie
                                                 heure_good = Time.new(jour_start.year, jour_start.month, jour_start.day, heure_choisie, 0, 0)
                                                 pday_start = heure_good.to_i
                                                 Unan.table_programs.set(program_id, { current_pday_start: pday_start } )
                                             end
                                         else
                                             # Ça n'a pas de sens pour un rythme qui ne correspond
                                             # pas à : 1 jour-programme = 1 jour réel
                                         end
                                     end
                                 rescue Exception => e
                                     log "Impossible de mettre l'heure d'envoi du rapport quotidien à l'heure choisie (#{heure_choisie})…", e
                                 end

                                 # Calcul du début du prochain jour
                                 (pday_start + 1.day.to_f * (5.0 / rythme)).to_i
                             end
    end
    # ---------------------------------------------------------------------

    # RETURN true s'il eest l'heure pour l'auteur de recevoir
    # son rapport quotidien
    def time_to_send_unan_report?
        return NOW > next_pday_start
    end

    # RETURN true si l'auteur veut recevoir son rapport
    # quotidiennement.
    def want_daily_mail?
        pds = preference(:pref_daily_summary)
        pds = true if pds === nil
        pds
    end

    # RETURN true si l'auteur a des nouveaux travaux ou
    # des travaux en dépassement
    def has_new_or_overrun_work?
        @has_new_or_overrun_work ||= begin
                                         cp = current_pday
                                         nombre_ofday    = cp.aworks_ofday.count
                                         nombre_overrun  = cp.uworks_overrun.count
                                         nombre_ofday > 0 || nombre_overrun > 0
                                     end
    end

    # RETURN l'heure à laquelle l'auteur veut peut-être qu'on
    # lui envoie son rapport.
    def heure_envoi_rapport
        @heure_envoi_rapport ||= preference(:dayly_mail_hour).to_i
    end

    # True si le temps du mail est fixé, false dans le cas
    # contraire
    def fixed_time_mail
        @fixed_time_mail ||= !!preference(:fixed_time_mail)
    end

    def preference key
        table_variables.get(where: "name = 'pref_#{key}'")
    end

    # Toutes les tables DISTANTES de l'auteur
    def table_variables
        @table_variables ||= site.dbm_table(:users_tables, "variables_#{id}")
    end
    def table_works
        @table_works ||= site.dbm_table(:users_tables, "unan_works_#{id}")
    end
    def table_quiz
        @table_quiz ||= site.dbm_table(:users_tables, "unan_quiz_#{id}")
    end
    def table_pages_cours
        @table_pages_cours ||= site.dbm_table(:users_tables, "unan_pages_cours_#{id}")
    end

end
DUser.init
