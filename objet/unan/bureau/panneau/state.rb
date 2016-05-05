# encoding: UTF-8
=begin

Méthodes d'helper pour le panneau "État" du bureau de programme

=end
class Unan
class Program

  # Calcul de la fin approximative du programme
  #
  # Le calcul se fait de cette façon : on prend le
  # jour-programme actuel, on calcul le nombre de jours
  # restants, on les "multiplie" par le
  # rythme courant et on ajoute à la date courante
  def fin_approximative as = :nombre
    @fin_approximative ||= begin
      NOW.to_i + (nombre_pdays_restants * 1.days * coefficient_duree).to_i
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
      366 - self.current_pday
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
      Unan::Program::RYTHMES[rythme][:hname].in_span +
      case true
      when rythme == 5 then "&nbsp;(1 jour réel = 1 jour-programme)"
      when rythme > 5  then "&nbsp;(1 jour réel = #{(coefficient_duree).round(2)} jours-programme)"
      when rythme < 5  then "&nbsp;(1 jour-programme = #{(coefficient_duree).round(2)} jours réels)"
      end.in_span()
    end
  end

  # Retourne le nombre de jour réel depuis le
  # début du programme
  def nombre_jour_reels_from_start as = :nombre
    @jrs ||= begin
      ((NOW.to_i - created_at) / 1.days)
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
