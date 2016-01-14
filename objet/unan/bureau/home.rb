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

  # {StringHTML} Return le code HTML pour les formulaires de la
  # rangée de définition du partage. Mis dans un helper ici pour
  # être utilisé notamment dans le panneau "Projet" et dans le
  # panneau "Préférences"
  def row_form_sharing
    form.field_select("Partage", 'sharing', nil, {values: Unan::SHARINGS, selected: user.projet.sharing , text_before:"Peut suivre ce projet : ", warning: (user.projet.sharing == 0)}) +
    form.field_description("Définissez ici qui peut suivre votre projet, c'est-à-dire consulter votre parcours, vos points, etc.")
  end

  # {String} Return un texte si des données sont manquantes pour la cible
  # +target+. Ce texte est une liste humaine des données manquantes en fonction
  # de la cible
  # Cette méthode est utilisée au-dessus des formulaires pour indiquer
  # les données manquantes qu'il convient de régler, par exemple le
  # partage du projet ou encore son titre.
  # Si true, ajoute un texte dans le panneau invitant l'auteur à définir les
  # données manquantes
  # @usage
  #   <% if missing_data(<:target>) %>
  #     <p>... on indique que des données manquent <%= missing_data(<:target>) %> ..</p>
  #   <% end %>
  def missing_data target # :projet, :preferences, etc.
    @missing_data ||= Hash::new

    @missing_data[target] ||= begin
      errors = Array::new
      case target
      when :projet
        errors << "le titre"    if user.projet.titre.nil_if_empty.nil?
        errors << "le résumé"   if user.projet.resume.nil_if_empty.nil?
        errors << "le support"  if user.program.type_support_id == 0
        errors << "le partage"  if user.projet.sharing == 0
      when :preferences
        errors << "le partage"  if user.projet.sharing == 0
      else
        return false
      end
      errors.pretty_join
    end
  end


  # Bouton submit
  # Pour avoir une cohérence entre les panneaux
  # @usage    bureau.submit_button
  def submit_button name = "Enregistrer"
    @submit_button ||= begin
      subbtn = form.submit_button(name)
      subbtn.sub!(/class="btn"/, 'class="btn tiny tres discret"')
    end
  end

end #/Bureau
end #/Unan

case param(:operation)
when 'bureau_save_preferences'
  bureau.save_preferences
when 'bureau_save_projet'
  bureau.save_projet
when 'bureau_save_travail'
  bureau.save_traail
end
