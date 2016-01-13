# encoding: UTF-8
=begin
Noter que c'est un singleton et que la méthode `bureau` le renvoie.
Donc toutes les méthodes de ce module peuvent être appelées de n'importe
où par :
    bureau.<methode> ...
=end
# Beaucoup de formulaires dans ce bureau
site.require 'form_tools'

class Unan
class Bureau

  # Données des onglets du bureau Un An Un Script
  ONGLETS = {
    state:        {id: :state,        titre:"État",     plain_titre: "État général du programme"},
    projet:       {id: :projet,       titre:"Projet"},
    travail:      {id: :travail,      titre:"Travail",  nombre: :travaux},
    pages_cours:  {id: :pages_cours,  titre:"Cours",    nombre: :pages},
    forum:        {id: :forum,        titre:"Forum",    nombre: :messages},
    quiz:         {id: :quiz,         titre:"Quiz",     nombre: :quiz},

    preferences:  {id: :preferences,  titre:"Préférences"}
  }

  # = main =
  #
  # {StringHTML} Retourne le code HTML pour l'onglet
  # courant (current_onglet)
  def panneau_courant
    (data_onglet[:plain_titre]||data_onglet[:titre]).in_h3 +
    Vue::new(current_onglet.to_s, folder_panneaux, self).output
  end

  # {Symbol} ID de l'onglet courant
  # Est défini dans `cong` dans les paramètres
  def current_onglet
    @current_onglet ||= (param(:cong) || :state).to_sym
  end

  # Données dans ONGLETS de l'onglet courant
  def data_onglet
    @data_onglet ||= ONGLETS[current_onglet]
  end


  # = main =
  #
  # {StringHTML} Retourne le code HTML de la barre
  # d'onglets
  def bande_onglets
    ONGLETS.collect { |ong_id, ong_data| onglet(ong_data) }.join.in_ul(id:'bande_onglets')
  end


  def travaux_count
    @travaux_count ||= user.nombre_de(:travaux)
  end
  def pages_count
    @pages_count ||= user.nombre_de(:pages_cours)
  end
  def messages_count
    @messages_count ||= user.nombre_de(:messages_forum)
  end
  def quiz_count
    @quiz_count ||= user.nombre_de(:quiz)
  end


  # Retourne le code HTML pour l'onglet de données +data+
  def onglet data
    titre_onglet(data).in_a(href:"bureau/home?in=unan&cong=#{data[:id]}").in_li(class: (current_onglet == data[:id] ? 'actif' : nil ))
  end

  def titre_onglet data
    tit = data[:titre]
    if data[:nombre]
      nb = self.send("#{data[:nombre]}_count")
      tit << " (#{nb})" if nb > 0
    end
    tit
  end

end #/Bureau
end #/Unan
