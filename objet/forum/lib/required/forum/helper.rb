# encoding: UTF-8
=begin
Méthodes d'helper pour le forum
=end
class Forum
  # Rappel : C'est un SINGLETON

  # Pour écrire titre et sous-titre
  # @usage    <%= forum.titre_h1[("<sous titre>")] %>
  def titre_h1 sous_titre = nil
    t = "Forum".in_h1
    t << sous_titre.in_h2 unless sous_titre.nil?
    t
  end

  # Pour afficher les onglets généraux
  # @usage:  <%= forum.onglets %>
  def onglets
    "[ONGLETS]"
  end

end
