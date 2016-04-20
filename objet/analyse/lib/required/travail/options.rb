# encoding: UTF-8
class FilmAnalyse
class Travail


  # BIT 1 : la cible (le film, le fichier collecte, un fichier MD, etc.)
  def cible;  @cible    ||= options[0].to_i  end
  def hcible; @hcible   ||= DATA_CIBLES[cible][:hname] end

  # BIT 2 : la phase (création, modification, correction, etc.)
  def phase;  @phase    ||= options[1].to_i end
  def hphase; @hphase   ||= DATA_PHASES[phase][:hname] end

  # BIT 3 : État du travail (achevé, en cours, en pause, etc.)
  def state;  @state    ||= options[2].to_i             end
  def hstate; @hstate   ||= DATA_STATES[state][:hname]  end

end #/Travail
end #FilmAnalyse
