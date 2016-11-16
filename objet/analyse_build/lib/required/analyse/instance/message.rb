# encoding: UTF-8
class AnalyseBuild

  # Pour le suivi de la procédure de dépôt et de traitement.
  # Sans argument, la méthode retourne le suivi. Sinon, elle ajoute
  # le message +mess+
  #
  def suivi mess = nil
    if mess.nil?
      if @suivi.nil?
        return ''
      else
        'Suivi du dépôt et du traitement des fichiers'.in_h3 +
        @suivi.join("\n").in_pre
      end
    else
      @suivi ||= Array.new
      @suivi << mess
    end
  end

end
