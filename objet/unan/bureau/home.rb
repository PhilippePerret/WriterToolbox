# encoding: UTF-8
=begin
Noter que c'est un singleton et que la méthode `bureau` le renvoie.
Donc toutes les méthodes de ce module peuvent être appelées de n'importe
où par :
    bureau.<methode> ...
=end
class Unan
class Bureau
  include Singleton

  # Données des onglets du bureau Un An Un Script
  ONGLETS = {
    state:        {id: :state,        titre:"État"},
    travail:      {id: :travail,      titre:"Travail",  nombre: :travaux},
    pages_cours:  {id: :pages_cours,  titre:"Cours",    nombre: :pages},
    forum:        {id: :forum,        titre:"Forum",    nombre: :messages},
    quiz:         {id: :quiz,         titre:"Quiz",     nombre: :quiz},

    preferences:  {id: :preferences,  titre:"Préférences"}
  }

  # {Symbol} ID de l'onglet courant
  # Est défini dans `cong` dans les paramètres
  def current_onglet
    @current_onglet ||= (param(:cong) || :state).to_sym
  end

  # = main =
  #
  # {StringHTML} Retourne le code HTML pour l'onglet
  # courant (current_onglet)
  def panneau_courant
    "C'est le panneau de l'onglet #{current_onglet.inspect}".in_div
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

  def panneau_onglet onglet_id, is_current = false
    "C'est le panneau de l'onglet #{onglet_id.inspect}".in_div(class:(is_current ? "actif" : nil))
  end
end #/Bureau
end #/Unan

def bureau
  @bureau ||= Unan::Bureau::instance
end
