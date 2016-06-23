# encoding: UTF-8
=begin

  Extension de la class User::CurrentPDay pour faire le
  bilan du jour courant de l'auteur.

  Que doit faire ce bilan ? Il doit permettre d'établir le mail
  quotidien qui sera envoyé à l'auteur pour lui dire où il en
  est.

  Ce mail lui signale :

    - Les nouveaux travaux (ce sont les travaux du jour qui n'ont
      pas encore d'instance work)
    - Les travaux à poursuivre (ce sont les travaux qui ont une
      instance work — donc ont été démarrés — mais qui ne sont
      pas terminés)
      On distingue parmi eux :
      - les travaux sans retard
      - les travaux en retard

  HASH DES WORKS

    La plupart des méthodes ci-dessous retournent des Array de
    hash de travaux. Il peut s'agir de travaux absolus ou de
    travaux de l'auteur.

    Pour les hash de absolute-works, on trouve dans chaque élément
      :id, :titre, :duree, :pday
      (:pday n'est pas une donnée qui appartient à la table, elle a
       été ajoutée, et on peut trouver plusieurs même abs-works dans
       les listes, à deux jours différents)

    Pour les hash de works d'auteur, on trouve dans chaque élément :
      :id, :abs_works_id, :abs_pday


=end
class User
class CurrentPDay

  # ---------------------------------------------------------------------
  #   Quelques raccourcis utiles
  # ---------------------------------------------------------------------
  def program;    @program    ||= auteur.program  end
  def program_id; @program_id ||= program.id      end

  # ---------------------------------------------------------------------
  #   Les informations importantes pour le mail quotidien
  # ---------------------------------------------------------------------

  # Array de hash contenant les travaux inachevés
  #
  # Chaque élément est un Hash contenant :
  #   :pday       Le jour-programme du travail
  #   :awork_id   L'identifiant absolu du travail absolu
  #   :uwork_id   L'identifiant du travail de l'auteur
  #   :status     Le statut du travail
  #
  def uworks_undone
    releve_done_and_undone if @uworks_undone === nil
    @uworks_undone
  end

  # Travaux récents, c'est-à-dire terminés dans les 10
  # jours programmes précédents
  def uworks_recents
    releve_done_and_undone if @uworks_recents === nil
    @uworks_recents
  end

  # Les nouveaux travaux. Ce sont les travaux du jour, qui
  # ne possèdent pas encore d'instance work pour l'auteur.
  # Rappel : Un travail ne possède une instance Works que
  # lorsqu'il est démarré par l'auteur.
  #
  # Noter que c'est un simple raccourci pour la clarté du nom
  # de la méthode.
  #
  # Pour connaitre la constitution de chaque élément de l'array,
  # cf. ci-dessus HASH DES WORKS
  def uworks_ofday
    decompose_travaux if @uworks_ofday === nil
    @uworks_ofday
  end

  # Array des travaux en cours sans retard
  #
  # Donc des travaux qui ont été démarrés et qui ne sont
  # pas en dépassement d'échéance.
  #
  # La propriété :reste des hash définit le nombre de
  # jours-programme restant. Il suffit de la convertir
  # suivant le rythme du programme pour savoir le temps
  # exact restant.
  #
  # Chaque hash est constitué des éléments habituel :
  #   {:awork_id, :uwork_id, :pday}
  # auxquels s'ajoutent :
  #   {:reste} (nombre de jours restants avant l'échéance)
  #   Ce nombre peut être égal à zéro
  #
  def uworks_goon
    decompose_travaux if @uworks_goon === nil
    @uworks_goon
  end

  # Array des travaux en dépassement de temps
  # La propriété :overrun des hash contient le nombre de
  # jours de dépassement, qui est forcément égal à 0
  #
  # Noter qu'un travail non démarré peut être aussi en
  # dépassement, mais on s'en fiche ici puisque le travail
  # non démarré sera pris en compte dans la liste des
  # travaux qui doivent être démarrés.
  #
  # Chaque hash est constitué des éléments habituel :
  #   {:awork_id, :uwork_id, :pday}
  # auxquels s'ajoutent :
  #   {:overrun} (nombre de jours de dépassement)
  def uworks_overrun
    decompose_travaux if @uworks_overrun === nil
    @uworks_overrun
  end

  # Les travaux qui auraient dû être démarrés depuis
  # au moins la veille.
  #
  # Chaque hash est constitué des éléments habituel :
  #   {:awork_id, :uwork_id, :pday}
  # auxquels s'ajoutent :
  #   {:since} (nombre de jours de dépassement)
  #
  # En plus des données normales, les hash contiennent
  # la propriété :since qui définit depuis combien de
  # jours-programme le travail aurait dû être démarré
  #
  def uworks_unstarted
    decompose_travaux if @uworks_unstarted === nil
    @uworks_unstarted
  end

  # Array de Hash contenant les travaux effectués jusqu'à
  # ce jour.
  # Eléments constitués comme ceux de uworks_undone
  def uworks_done
    releve_done_and_undone if @uworks_done === nil
    @uworks_done
  end


  # / Fin des méthodes utiles pour le bilan de mail
  # ---------------------------------------------------------------------

  # Méthode qui va permettre de ne conserver que les
  # travaux qui ne sont pas achevés de l'ensemble de
  # tous les travaux jusqu'au jour courant.
  #
  # Cette méthode produit :
  #   - La liste des travaux terminés
  #     => @uworks_done
  #   - La liste des travaux en dépassement
  #     => @uworks_overrun
  #     La propriété :overrun est ajouté aux hash avec le nombre
  #     de jours-programme de dépassement.
  #     Noter que ce sont des travaux qui ont forcément
  #     été démarrés, sinon c'est dans les travaux à
  #     démarrer qu'ils apparaitront.
  #   - La liste des travaux qui se poursuivent
  #     => @uworks_goon
  #     La propriété :reste est ajoutée au hash, avec le nombre
  #     de jours-programme restant.
  #     Un "travail qui se poursuit" est un travail qui :
  #     - a été démarré (possède son instance work)
  #     - n'a pas dépassé son échéance
  #   - La liste des travaux à démarrer (hormis les travaux
  #     du jour-programme courant)
  #     @uworks_unstarted
  #
  def decompose_travaux

    # Les travaux en dépassement
    @uworks_overrun     = []
    # Les travaux à poursuivre
    @uworks_goon  = []
    # Les travaux qui auraient dû être démarrés
    @uworks_unstarted   = []
    # Les nouveaux travaux du jour
    @uworks_ofday       = []

    # On ne garde des travaux absolus que ceux qui n'ont pas
    # été terminés. Noter qu'on ne peut pas utiliser
    # uworks_undone qui ne contient que les travaux démarrés
    aworks_until_today.each do |haw|
      # debug "[decompose_travaux]---"
      # debug "--- haw: #{haw.inspect}"
      # On exclue les travaux terminés
      wkey = "#{haw[:id]}-#{haw[:pday]}"
      reste = (haw[:pday] + haw[:duree]) - day
      if auworks_done_ids.key?( wkey )
        # Un travail terminé
        # Inutile de le consigner dans @uworks_done puisque
        # cette liste a due être établie justement pour définir
        # le hash auworks_done_ids utilisé ici.
        # debug "    Terminé"
      elsif auworks_undone_ids.key?( wkey )
        uwork_id = auworks_undone_ids[wkey][:uwork_id]
        # Un travail non terminé
        if reste < 0
          # Un travail EN DÉPASSEMENT de temps
          @uworks_overrun << haw.merge(awork_id: haw[:id], uwork_id: uwork_id, overrun: - reste)
          # debug "    En dépassement"
        elsif haw[:pday] < day
          # Si le jour-programme de ce travail est inférieur à
          # aujourd'hui, c'est un travail à poursuivre
          # Un travail à poursuivre normalement
          @uworks_goon << haw.merge(awork_id: haw[:id], uwork_id: uwork_id, reste: reste)
          # debug "    À poursuivre"
        end
      else
        # C'est un travail non démarré, soit un travail
        # du jour soit un travail qui aurait dû être
        # démarré avant
        haw.merge!( awork_id: haw[:id] )
        if haw[:pday] < day
          @uworks_unstarted << haw.merge(since: day - haw[:pday])
        else
          @uworks_ofday << haw
        end
      end
    end

  end


  # Un Hash spécial qui contient en clé un identifiant
  # composé de <id absolute work>-<jour-programme> pour
  # savoir que le travail correspondant à ces deux données
  # (le work absolu et le jour-programme) a été fait.
  # C'est nécessaire car un même travail absolu peut être
  # utilisé plusieurs jour-programme différent.
  #
  # La valeur contient :
  #   :awork_id   Identifiant du work absolu
  #   :uwork_id   Identifiant du work de l'auteur
  #   :pday       Le jour-programme de ce travail
  #
  def auworks_done_ids
    releve_done_and_undone if @auworks_done_ids === nil
    @auworks_done_ids
  end
  def auworks_undone_ids
    releve_done_and_undone if @auworks_undone_ids === nil
    @auworks_undone_ids
  end


  # Grande méthode relevant les listes de travaux suivants :
  #   - les travaux achevés
  #     => @uworks_done
  #   - les travaux achevés dans les 10 derniers jours-programme
  #     => @uworks_recents
  #     Note : ils sont aussi dans @uworks_done
  #   - les travaux inachevés
  #     => @uworks_undone
  #
  # Fait également deux listes utiles pour trouver les travaux
  # absolus qui n'ont pas été démarrés :
  #   - Hash des travaux faits par jour (clé = "<abs-work-id>-<pday>")
  #     => @auworks_done_ids
  #   - Hash des travaux non faits par jour (clé identique)
  #     => @auworks_undone_ids
  #
  def releve_done_and_undone
    drequest = {
      where: "program_id = #{program_id} AND created_at < #{NOW + 1}",
      colonnes: [:abs_pday, :abs_work_id, :status]
    }
    @uworks_done        = []
    @uworks_recents     = []
    @uworks_undone      = []
    @auworks_done_ids   = {}
    @auworks_undone_ids = {}
    auteur.table_works.select(drequest).each do |huw|
      duwork = {
        awork_id: huw[:abs_work_id],
        uwork_id: huw[:id],
        pday:     huw[:abs_pday]
        }
      # Celui-ci contient en plus le status, et
      # quelques autres informations
      dnwork = huw.merge(
        pday:       huw.delete(:abs_pday),
        awork_id:   huw.delete(:abs_work_id),
        uwork_id:   huw.delete(:id)
      )
      sid = "#{dnwork[:awork_id]}-#{dnwork[:pday]}"
      # debug "dnwork = #{dnwork.inspect}"
      if dnwork[:status] == 9
        # Travaux achevé
        @uworks_done << dnwork
        @auworks_done_ids.merge!(sid => duwork)
        if dnwork[:pday] > day - 10
          @uworks_recents << dnwork
        end
      else
        # Travaux inachevés
        @uworks_undone << dnwork
        @auworks_undone_ids.merge!(sid => duwork)
      end
    end
  end



  # Liste des travaux absolus du jour courant
  #
  # Cette donnée est calculée par abs_works_until_today
  def todays_aworks
    aworks_until_today if @todays_aworks === nil
    @todays_aworks
  end

  # Tous les travaux absolus depuis le jour courant
  #
  # La méthode produit aussi la propriété @todays_abs_works
  # qui contient la liste Array des Hashs de données des
  # travaux d'aujourd'hui.
  #
  # C'est un ARRAY qui contient les HASH de chaque travail
  # depuis le début.
  # Noter qu'on a ajouté dans ce hash la propriété :pday qui
  # indique le jour-programme du travail (ce qui n'est pas indiqué
  # normalement, un travail pouvant appartenir à plusieurs jours)
  #
  def aworks_until_today
    @aworks_until_today ||= begin
      # Pour consigner le résultat final
      arr_final = []
      @todays_abs_works = []
      req_pdays = {
        where:      "id <= #{day}",
        colonnes:  [:id, :works]
      }
      # Pré-requête pour les works absolus
      req_works = {
        where:      nil,
        colonnes:   [:id, :duree]
      }
      # On boucle sur tous les jours de puis le premier jusqu'au
      # jour courant pour relever tous les travaux à faire, dans
      # leur intégralité.
      Unan.table_absolute_pdays.select(req_pdays).each do |hpday|
        unless hpday[:works].nil_if_empty == nil
          works_ids = hpday[:works].split(' ').join(',')
          req_works.merge!(where: "id IN (#{works_ids})")
          all_works_of_pday =
            Unan.table_absolute_works.select(req_works).collect do |hwork|
              hwork.merge(pday: hpday[:id])
            end
          arr_final += all_works_of_pday
          if hpday[:id] == self.day # le jour courant
            @todays_aworks = all_works_of_pday
          end
        end
      end
      arr_final
    end #/begin
  end

end #/CurrentPDay
end #/User
