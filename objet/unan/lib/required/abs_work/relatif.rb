# encoding: UTF-8
class Fixnum
  # Prend une valeur absolue (par exemple un nombre de jours) et
  # retourne la valeur réelle en fonction du rythme du programme
  # +coef_duree+ Le coefficient de durée
  def as_real_duree(coef_duree)
    (self.to_f * coef_duree).to_i
  end
end #/Fixnum
class Float
  def as_real_duree(coef_duree)
    (self * coef_duree).to_i
  end
end #/Float

class Unan
class Program
class AbsWork


  # Des données supplémentaires qu'on peut transmettre à l'instance,
  # qui peuvent servir notamment à l'affichage de la carte du
  # travail.
  #
  # Cette propriété a été ajoutée lorsqu'on ne partait plus de
  # l'instance `Work` d'un travail de l'auteur pour afficher le
  # travail (car cette instance n'existe que lorsque l'auteur
  # a démarré le travail) mais de l'instance AbsWork courante.
  # Mais pour calculer certains temps, comme le temps restant
  # avant d'accomplir le travail, il faut connaitre le début
  # du travail. Cette donnée se trouve dans :relative_data,
  # avec la clé :indice_pday qui définit le jour où le travail
  # a été confié. En le comparant au jour-programme courant,
  # on peut déterminer le nombre de jours restant.
  #
  # Data qu'on peut trouver jusqu'à présent
  #   :user_id              ID de l'auteur du travail
  #   :indice_pday          Indice du jour où le travail a démarré
  #   :indice_current_pday  Indice du jour de travail courant
  #   :work_id              ID du travail relatif
  #
  attr_reader :relative_data
  def set_relative_data h
    @relative_data = h
    return self
  end

  # Pour pouvoir définir et récupérer le jour-programme du travail
  # absolu à l'aide de :
  #   <abs work>.pday= <value>
  #   <abs wrok>.pday # => valeur
  #
  # Ces méthodes ont été ajoutées pour simplifier le travail sur les
  # quiz
  def pday= value; @pday = value  end
  def pday; @pday ||= rwork.indice_pday end

  # {Unan::Program::AbsWork::RelatifWork} Le travail relatif, s'il existe.
  def rwork
    @rwork ||= begin
      RelatifWork.new(self, relative_data || {user_id: user.id, work_id: nil})
    end
  end

  # ---------------------------------------------------------------------
  #   Class Unan::Program::AbsWork::RelatifWork
  # ---------------------------------------------------------------------

  class RelatifWork

    # Instance AbsWork du travail absolu
    attr_reader :abs_work

    # Données relative, c'est-à-dire les données Hash
    # récupérée (contient des chose comme :indice_current_pday)
    attr_reader :data

    def initialize abs_work, data
      raise "Impossible de définir un travail relatif avec des données relatives nulles" if data.nil?
      @abs_work = abs_work
      @data     = data
#       flash <<-CODE
# <div class='small'>
# Rythme : #{auteur.program.rythme}<br>
# Coefficient durée : #{coef_duree}<br>
# Jour-programme courant : #{auteur.program.current_pday}<br>
# Indice PDay du travail : #{indice_pday}<br>
# </div>
#       CODE
    end

    # ---------------------------------------------------------------------
    #  Données dans @data
    # ---------------------------------------------------------------------
    def user_id             ; @user_id              ||= data[:user_id]      end
    def indice_pday         ; @indice_pday          ||= data[:indice_pday]  end
    def indice_current_pday ; @indice_current_pday  ||= data[:indice_current_pday] end
    def work_id             ; @work_id              ||= data[:work_id]      end
    alias :id :work_id
    # ---------------------------------------------------------------------
    #   Données du abs_work (raccourcis)
    # ---------------------------------------------------------------------

    # Durée en nombre de jours-programme du travail
    #
    def duree
      @duree      ||= begin
        if abs_work.nil?
          error "Le travail absolu est nil…"
          1
        else
          abs_work.duree || 1
        end
      end
    end
    def coef_duree  ; @coef_duree ||= auteur.program.coefficient_duree end

    # ---------------------------------------------------------------------
    #   Données volatiles
    # ---------------------------------------------------------------------
    def auteur
      @auteur ||= User.new(user_id)
    end
    # Program de ce travail relatif
    def program
      @program ||= auteur.program
    end

    # {Unan::Program::Work} Instance du travail (Work) si
    # le travail a été démarré
    # OU NIL si le travail n'a pas encore été démarré
    def work
      @work ||= begin
        work_id.nil? ? nil : Unan::Program::Work.get(program, work_id)
      end
    end

    def work_relatif?
      work_id != nil
    end

    # Jour-programme courant de l'auteur.
    # C'est ce jour courant qui permet de déterminer toutes les
    # autres valeurs de temps. Par exemple, si l'auteur en est
    # à son 4e jour et que le jour-programme de ce relatif est
    # 2 (indice_pday) on sait que ce travail a commencé deux jours
    # plus tôt.
    def auteur_pday
      @auteur_pday ||= auteur.program.current_pday
    end

    # Durée réelle du travail en nombre de jours en fonction du
    # rythme adopté par l'auteur.
    def duree_real      ; @duree_real ||= duree.as_real_duree(coef_duree) end
    # Durée absolue du travail en secondes
    def duree_secondes  ; @duree_secondes ||= duree.days  end
    # Durée réelle en secondes
    def duree_secondes_real; @dursecreal ||= duree_secondes.as_real_duree(coef_duree) end

    # {Fixnum} Timestamp (secondes) du démarrage du travail
    # Il a été enregistré (dans created_at du work) au moment où
    # l'auteur cliquait sur « Démarrer ce travail »
    def started_at
      @started_at ||= (work_relatif? ? work.created_at : '- Non défini -')
    end

    # {Fixnum} Timestamp (en secondes) de la fin attendue du travail
    # Noter que c'est le temps réel, en tenant compte du rythme
    # du programme de l'auteur.
    # C'est donc la date (secondes) du démarrage du travail à laquelle
    # on ajoute la durée réelle en secondes.
    def expected_at
      @expected_at ||= begin
        work_relatif? ? (started_at + duree_secondes_real) : '- Non défini -'
      end
    end

    # ---------------------------------------------------------------------
    #   Nouvelles méthodes pour calculer les dépassements justes
    # ---------------------------------------------------------------------

    # Nombre de secondes de différence entre le temps courant et
    # l'échéance du travail.
    # Note : Si ce nombre est positif, le travail n'est pas en dépassement,
    # si ce nombre est strictement négatif, le travail est en dépassement (en
    # vérité, il faut qu'il soit en dépassement d'une heure)
    def real_diff_secondes
      @real_diff_secondes ||= expected_at - Time.now.to_i
    end
    # Le nombre de jours de différences (négatif si le travail
    # est en dépassement)
    def real_diff_jours
      @real_diff_jours ||= (real_diff_secondes.to_f / 1.day).floor
    end

    # Retourne true si le travail est en dépassement d'une heure
    def depassement?
      real_diff_secondes < 0
    end

    # Retourne le nombre de jours de dépassement ou nil s'il n'y en
    # a pas.
    # ATTENTION : c'est un nombre POSITIF car si c'est un dépassement,
    # real_diff_jours est toujours négatif.
    def depassement
      @depassement ||= (depassement? ? - real_diff_jours : nil)
    end
    def human_depassement
      @human_depassement ||= begin
        if work_relatif?
          s = depassement > 1 ? 's' : ''
          "#{depassement} jour#{s}"
        else
          '- Non défini -'
        end
      end
    end
    # Retourne le nombre de jours restant ou nil si on est en
    # dépassement
    def reste
      @reste ||= ( depassement? ? nil : real_diff_jours )
    end
    # La même donnée au format humain
    def human_reste
      @human_reste ||= begin
        if work_relatif?
          s = reste > 1 ? 's' : ''
          "#{reste} jour#{s}"
        else
          '- Non défini -'
        end
      end
    end


    # Pour le moment, on ne peut pas savoir si le travail a
    # été achevé, donc on le compte comme non achevé
    def completed?
      false
    end

    # Un travail est considéré comme démarré s'il possède
    # un identifiant
    def started?
      # debug "started? = #{(work_id!=nil).inspect}"
      work_id != nil
    end

    # ---------------------------------------------------------------------
    #   Méthodes fonctionnelles
    # ---------------------------------------------------------------------


    # ---------------------------------------------------------------------
    #   Méthodes d'helper
    # ---------------------------------------------------------------------

    # = main =
    #
    # RETURN Le code HTML du message qui doit donner les informations
    # temporelles du travail, c'est-à-dire la durée qu'il doit faire,
    # sa date de début et de fin, si l'échéance est dépassée, etc.
    def div_echeance
      return '' if completed? || false == work_relatif?
      mess_duree, css   = message_duree_travail
      mess_echeance     = message_echeance_travail( css )
      mess_reste_jours  = message_jours_restants_or_depassement
      (
        mess_reste_jours      +
        mess_duree.in_div     +
        mess_echeance.in_div
      ).in_div(class:'dates')
    end

    def message_duree_travail
      css  = ['exbig']
      @doit, avez =
        if depassement?
          css << "warning"
          ["aurait dû", "aviez"]
        else
          ["doit", "avez"]
        end
      mess = "Ce travail #{@doit} être accompli en #{duree_secondes_real.as_jours}."
      [mess, css]
    end
    def start_as_time
      @start_as_time ||= Time.at(started_at)
    end
    def expected_as_time
      @expected_as_time ||= Time.at(expected_at)
    end
    def message_echeance_travail css
      start_with_hour = (start_as_time.hour + start_as_time.min) > 0
      expec_with_hour = (expected_as_time.hour + expected_as_time.min) > 0
      start_h = "#{started_at.as_human_date(true, start_with_hour, nil, 'à')}"
      end_h   = "#{expected_at.as_human_date(true, expec_with_hour, nil, 'à')}"
      end_h   = end_h.in_span(class: css.join(' '))
      "Il a débuté le #{start_h}<br>Il #{@doit} être achevé le #{end_h}."
    end

    def message_jours_restants_or_depassement
      @message_jours_restants_or_depassement ||= begin
        if depassement?
          "Vous êtes en dépassement de <span class='exbig'>#{human_depassement}</span>.".in_div(class:'warning').in_div(class:'depassement')
        else
          (
            'Reste'.in_span(class:'libelle va_bottom', style: 'margin-right:1em !important') +
            human_reste.in_span(class:'mark_fort')
          ).in_span(class:'fright', style:'margin-top:4px;display:inline-block;margin-left:1em;vertical-align:middle')
        end

      end
    end

  end #/RelatifWork

end #/AbsWork
end #/Program
end #/Unan
