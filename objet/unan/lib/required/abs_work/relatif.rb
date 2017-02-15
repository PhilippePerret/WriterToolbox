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
# Différence : #{diff_jours} / #{diff_jours_real}
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

    # Durée réelle en jours
    def duree_real
      @duree_real ||= duree.as_real_duree(coef_duree)
    end
    # Durée absolue en secondes
    def duree_secondes
      @duree_secondes ||= duree.days
    end
    # Durée réelle en secondes
    def duree_secondes_real
      @duree_secondes_real ||= duree_secondes.as_real_duree(coef_duree)
    end

    # {Fixnum} Timestamp (secondes) du démarrage du travail
    # Pris vraiment dans le created_at de la donnée work, car
    # ne fonctionnait pas, avant, avec le Today.start etc.
    def started_at
      @started_at ||= begin
        if work_relatif?
          # (Today.start - diff_jours_real.days)
          work.created_at
        else
          '- Non défini -'
        end
      end
    end

    # {Fixnum} Timestamp (en secondes) de la fin attendue du travail
    # Noter que c'est le temps réel, en tenant compte du rythme
    # du programme de l'auteur.
    def expected_at
      @expected_at ||= begin
        if work_relatif?
          (started_at + duree_secondes_real)
        else
          '- Non défini -'
        end
      end
    end

    # Le nombre de jours restants renvoyant une donnée
    # complètement absurde, on calcule maintenant le nombre
    # de jours restants par rapport à la vraie date de
    # démarrage et la vraie date de fin attendue
    def reste_jours_from_real_times
      @reste_secondes_from_real_times ||= begin
        if work_relatif?
          jrs = (expected_at - Time.now.to_i)/1.day
          s = jrs > 1 ? 's' : ''
          "#{jrs} jour#{s}"
        else
          '- Non défini -'
        end
      end
    end

    # {Fixnum} Nombre de jour-programme de différence
    # entre le début du travail et le jour-programme
    # courant (qui peut être aujourd'hui).
    # Le travail est en dépassement si cette différence
    # de jour est supérieure à la durée du travail.
    #
    # Noter qu'il s'agit du nombre de jours-programme,
    # pas du nombre de jours réels. Pour avoir le nombre
    # de jours réels, utiliser la données `diff_jours_real`
    #
    def diff_jours
      @diff_jours ||= begin
        if work_relatif?
          # debug "[diff_jours awork ##{abs_work.id} « #{abs_work.titre} »]\nauteur_pday = #{auteur_pday}\nindice_pday = #{indice_pday}\ndiff_jours = #{auteur_pday - indice_pday}"
          auteur_pday - indice_pday
        else
          '- Non défini -'
        end
      end
    end
    def diff_jours_real
      @diff_jours_real ||= begin
        if work_relatif?
          diff_jours.as_real_duree(coef_duree)
        else
          '- Non défini -'
        end
      end
    end

    # {Fixnum} Nombre de jours de dépassement ou
    # 0 ou nombre négatif s'il n'y a pas de dépassement
    def depassement
      @depassement ||= begin
        if work_relatif?
          # debug "[depassement awork ##{abs_work.id}]\ndiff_jours = #{diff_jours}\nduree = #{duree}\n=> depassement = #{diff_jours - duree}"
          (diff_jours - duree) rescue 0
        else
          '- Non défini -'
        end
      end
    end
    def depassement_real
      @depassement_real ||= depassement_real.as_real_duree(coef_duree)
    end
    def human_depassement
      @human_depassement ||= begin
        s = depassement_real > 1 ? 's' : ''
        "#{depassement_real} jour#{s}"
      end
    end
    # {Fixnum} Nombre de jours restants (inverse
    # du dépassement)
    # RENVOIE UN RÉSULTAT FAUX
    def reste
      @reste ||= - depassement
    end
    # RENVOIE UN RÉSULTAT FAUX
    def reste_real
      @reste_real ||= reste.as_real_duree(coef_duree)
    end
    # RENVOIE UN RÉSULTAT FAUX
    def human_reste
      @human_reste ||= begin
        s = reste > 1 ? 's' : ''
        "#{reste_real} jour#{s}"
      end
    end

    # ---------------------------------------------------------------------
    #   Méthodes d'état
    # ---------------------------------------------------------------------

    # Retourne TRUE si le travail est en dépassement
    def depassement?
      @is_depassement ||= begin
        depassement.floor > 0
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
        # debug "reste_jours_from_real_times : #{reste_jours_from_real_times.inspect}"
        if depassement?
          "Vous êtes en dépassement de <span class='exbig'>#{depassement.days.as_jours}</span>.".in_div(class:'warning').in_div(class:'depassement')
        else
          (
            'Reste'.in_span(class:'libelle va_bottom', style: 'margin-right:1em !important') +
            reste_jours_from_real_times.in_span(class:'mark_fort')
          ).in_span(class:'fright', style:'margin-top:4px;display:inline-block;margin-left:1em;vertical-align:middle')
        end

      end
    end

  end #/RelatifWork

end #/AbsWork
end #/Program
end #/Unan
