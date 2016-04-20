# encoding: UTF-8
class FilmAnalyse
class Travail

  # ---------------------------------------------------------------------
  #   Enregistrées
  # ---------------------------------------------------------------------
  def film_id;    @film_id    ||= get(:film_id)           end
  def user_id;    @user_id    ||= get(:user_id)           end
  def options;    @options    ||= get(:options) || "111"  end
  def target_ref; @target_ref ||= get(:target_ref)        end
  # ---------------------------------------------------------------------
  #   Volatiles
  # ---------------------------------------------------------------------
  def film;     @film     ||= FilmAnalyse::Film::get(film_id) end
  def analyste; @analyste ||= User::get(user_id) end


  def cible_pour_action
    @cible_pour_action ||= begin
      c = DATA_CIBLES[cible][:action]
      # S'il y a une référence de cible, par exemple un nom de
      # fichier, on l'ajoute
      c << " (#{target_ref})" unless target_ref.nil?
      c
    end
  end
  def action; @action ||= DATA_PHASES[phase][:action] end

end #/Travail
end #/FilmAnalyse
