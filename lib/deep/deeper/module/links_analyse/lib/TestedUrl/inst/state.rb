# encoding: UTF-8
=begin

  Module de méthode par l'état (les méthodes-question) de l'url testée

=end
class TestedUrl

  # Retourne TRUE si la route commence par http:// ou https://
  def entete_http?
    !!route.match(/^https?:\/\//)
  end
  # Retourne TRUE si la route commence par http://www.laboiteaoutilsdelauteur.fr
  def full_url_base?
    !!route.start_with?(self.class::BASE_URL)
  end

  # Retourne TRUE si la route est simplement une ancre
  def ancre?
    route.start_with?('#')
  end

  # Retourne TRUE si c'est un lien externe
  def hors_site?
    @is_hors_site = (entete_http? && !full_url_base?) if @is_hors_site === nil
    if @is_hors_site
      puts "ROUTE HORS BASE (`route') : #{route}"
    end
    @is_hors_site
  end

end
