# encoding: UTF-8
=begin

  Module pour créer un travail (Unan::Program::Work)

  @usage

  C'est la méthode `Unan::Program::Work.start_work` qui doit être
  appelée en lui transmettant :

    - auteur      Instance de l'auteur du programme
    - awork_id    ID du travail absolu qu'il faut démarrer
    - work_pday   Indice du jour-programme du travail, juste pour vérification
                  et aussi, je crois, parce qu'un travail absolu peut
                  correspondre à plusieurs jours-programme et qu'il faut donc
                  le connaitre pour savoir de quel travail il s'agit.

=end

class Unan
class Program
class Work
  class << self

    # = main =
    #
    # Méthode principale pour démarrer le travail
    #
    # +awork_id+  ID absolu du travail
    # +work_pday+ Jour-programme pour savoir quand le travail est commencé
    #
    def start_work auteur, awork_id, work_pday
      # Checks
      awork_id > 0  || raise('L’ID du work absolu est impossible.')
      work_pday > 0 || raise('Le jour-programme du work doit être défini.')

      # Il faut que ce jour-programme soit inférieur ou égal au jour-programme
      # courant de l'auteur, sinon c'est impossible
      work_pday <= auteur.program.current_pday || raise('Ce jour-programme est impossible, voyons… (il est inférieur à votre jour-programme courant)')

      # Il faut vérifier que ce jour-programme définit bien ce travail
      # absolu. Dans le cas contraire, c'est un petit malin qui essaie
      # de passer en force
      ipday = Unan::Program::AbsPDay.new(work_pday)
      lworks = ipday.works(:as_ids)
      lworks.include?( awork_id) || raise("Aucun travail d'ID ##{awork_id} le #{work_pday}<sup>e</sup> jour-programme…")

      # Instance du nouveau travail
      work = create_new_work_for_user(
        user:         auteur,
        abs_work_id:  awork_id,
        indice_pday:  work_pday,
      )
      if work != nil
        work.started? || raise('Le travail devrait avoir été marqué démarré…')
      else
        # C'est une recréation accidentelle du travail, il ne faut rien faire
      end

    rescue Exception => e
      error e.message
    end
    # /start_work

    # Méthode à appeler pour créer le travail et le marquer
    # démarré.
    #
    # RETURN L'instance Unan::Program::Work créée Ou NIL si
    # le travail existait déjà.
    #
    # +data+ doit impérativement définir :
    #   :user_id ou :user     Auteur de ce travail
    #   :abs_work_id        {Fixnum}    Identifiant du travail absolu
    #   :indice_pday        {Fixnum}    Indice du PDay de ce travail
    #
    def create_new_work_for_user wdata
      auteur = wdata[:user] || User.new(wdata[:user_id])

      # Avant de créer le travail, il faut s'assurer qu'il
      # n'existe pas déjà, ce qui se produit lorsque l'user
      # recharche sa page
      awork_id = wdata[:abs_work_id]
      progr_id = auteur.program.id
      pday     = wdata[:indice_pday]
      where = {program_id: progr_id, abs_work_id: awork_id, abs_pday: pday}
      if auteur.table_works.count(where: where) > 0
        error 'Admin, je ne recrée pas le travail après rechargement de la page.' if OFFLINE
        return nil
      end

      # Pour le type de travail
      awork = Unan::Program::AbsWork.new(awork_id)
      datawok2save = {
        program_id:   progr_id,
        abs_work_id:  awork_id,
        abs_pday:     pday,
        status:       1,  # pour le marquer démarré
        options:      "#{awork.type_w.rjust(2,'0')}",
        created_at:   NOW,
        updated_at:   NOW
      }

      # Création de l'instance et enregistrement
      @id = auteur.table_works.insert( datawok2save )
      iwork = Unan::Program::Work.new( auteur.program, @id )
      return iwork
    end
    # /create_new_work_for_user

  end #/<<self Unan::Program::Work

end #/Work
end #/Program
end #/Unan
