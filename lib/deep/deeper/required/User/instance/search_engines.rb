# encoding: UTF-8
=begin

Module pour traiter le fait que l'user courant est un
moteur de recherche

=end

class User

  # GOOGLE
  REG_DNS_GOOGLE      = /^66\.249\.6[0-9]\.([0-9]{1,3})$/
  # EXABOT
  REG_DNS_EXABOT      = /178\.255\.215\.86/
  # MAJESTIC 12
  REG_DNS_MAJESTIC_12 = /144\.76\.61\.21/

  # Retourne true si l'user courant est un moteur
  # de recherche connu.
  def moteur_recherche?
    if @is_moteur_recherche === nil
      @is_moteur_recherche = cherche_if_moteur_recherche
    end
    @is_moteur_recherche
  end
  alias :seach_engine? :moteur_recherche?

  def exabot?
    if @is_exabot === nil
      cherche_if_moteur_recherche
      @is_exabot = @pseudo == "Exabot"
    end
    @is_exabot
  end
  def google?
    if @is_google === nil
      cherche_if_moteur_recherche
      @is_google = @pseudo == "Google"
    end
    @is_google
  end
  def majestic12?
    if @is_majestic12 === nil
      cherche_if_moteur_recherche
      @is_majestic12 = @pseudo == "Majestic 12"
    end
    @is_majestic12
  end

  # Cherche si le visiteur peut être un moteur de
  # recherche et définit son pseudo et son ID en
  # fonction du résultat.
  # RETURN True si un moteur de recherche a été
  # trouvé.
  def cherche_if_moteur_recherche
    pse, uid = case ip
    when REG_DNS_GOOGLE       then ["Google", 10]
    when REG_DNS_EXABOT       then ["Exabot", 11]
    when REG_DNS_MAJESTIC_12  then ["Majestic 12", 12]
    else [nil, nil]
    end
    unless pse.nil?
      @pseudo = pse
      @id     = uid 
    end
    return pse != nil
  end

end
