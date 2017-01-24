# encoding: UTF-8
# encoding: UTF-8
=begin

  Instance Connexions::IP
  -----------------------
  Pour le traitement d'un IP en particulier
  Méthodes d'helper.

=end
class Connexions
class IP

  # Le nom humain. Si l'adresse IP est connue, elle est remplacée
  # par ce nom, sinon elle reste telle quelle.
  # Donc la méthode renvoie une de ces deux formes :
  #   "123.58.589.125   "
  #   "Orange portails  "
  #
  # Si +longueur+ est fourni, on renvoie un texte de
  # cette longueur.
  #
  def human_name longueur = nil
    @human_name ||= begin
      ip # TODO Traiter
    end
    if longueur.nil?
      @human_name
    else
      @human_name.ljust(longueur)
    end
  end


end #/IP
end #/Connexions
