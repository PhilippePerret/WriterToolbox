# encoding: UTF-8
=begin

Méthodes d'helper pour le panneau "État" du bureau de programme

=end
class Unan
class Program

  # # Pour les essais avec un autre rythme
  # def rythme
  #   5
  # end



  def coef_rythme
    @coef_rythme ||= ( rythme.to_f / 5 )
  end

  # Calcul de la fin approximative du programme
  #
  # Le calcul se fait de cette façon : on prend le
  # jour-programme actuel, on calcul le nombre de jours
  # restants, on les "multiplie" par le
  # rythme courant et on ajoute à la date courante
  def fin_approximative as = :nombre
    @fin_approximative ||= begin
      NOW.to_i + (nombre_pdays_restants * 1.days / coef_rythme).to_i
    end
    case as
    when :human
      @fin_approximative.as_human_date
    else
      @fin_approximative
    end
  end

  def nombre_pdays_restants as = :nombre
    @nombre_pdays_restants ||= begin
      jrs = 366 - current_pday
      # On ajoute un jour sauf si on est en fin de journée
      jrs += 1 unless Time.now.hour > 16
      jrs
    end
    case as
    when :human
      s = @nombre_pdays_restants > 1 ? 's' : ''
      "#{@nombre_pdays_restants} jour#{s}"
    else
      @nombre_pdays_restants
    end
  end

  def rythme_humain
    @rythme_humain ||= begin
      Unan::Program::RYTHMES[rythme][:hname] +
      case true
      when rythme == 5 then " (1 jr réel = 1 jr-programme)"
      when rythme > 5  then " (1 jr réel = #{coef_rythme} jrs-programme)"
      when rythme < 5  then " (1 jr réel = #{(1 /coef_rythme).to_i} jrs-programme)"
      end
    end
  end

  # Retourne le nombre de jour réel depuis le
  # début du programme
  def nombre_jour_reels_from_start as = :nombre
    @jrs ||= begin
      ((NOW.to_i - created_at) / 1.days) + 1
    end
    case as
    when :human, :humain
      mark = @jrs == 1 ? "er" : "e"
      "#{@jrs}<sup>#{mark}</sup> jour"
    else
      @jrs
    end
  end


end #/Program
end #/Unan