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

  # Onglets du bureau Un An Un Script d'un user suivant le programme
  ONGLETS = {
    state:        {id: :state,        titre:"État",     plain_titre: "État général du programme"},
    projet:       {id: :projet,       titre:"Projet"},
    taches:       {id: :taches,       titre:"Tâches",   knombre: :tasks},
    pages_cours:  {id: :pages_cours,  titre:"Cours",    knombre: :pages_non_lues},
    forum:        {id: :forum,        titre:"Forum",    knombre: :messages},
    quiz:         {id: :quiz,         titre:"Quiz",     knombre: :quiz},

    preferences:  {id: :preferences,  titre:"Préférences"}
  }

  # ---------------------------------------------------------------------
  #   Messages communs à tous les panneaux
  # ---------------------------------------------------------------------

  # @usage : if works.count == 0
  #            ...
  def message_si_aucun_travail
    @message_si_aucun_travail ||= "<p class='grand air small'>Pas de tâches à accomplir… pas de pages de cours à lire… pas de questionnaire à remplir… Et si vous alliez faire un petit tour au parc ou en forêt ?…</p>"
  end

  # ---------------------------------------------------------------------
  #   Méthodes pour les travaux
  # ---------------------------------------------------------------------
  # {Array} Liste des instances Unan::Program::Travaux courantes
  # de l'user, pour boucler dessus et les afficher, ou autre
  # travail.
  def works
    @works ||= works_ids.collect { |wid| Unan::Program::Work::new(user.program, wid) }
  end

  # {Array} Liste ordonnée des IDs de travaux à accomplir par
  # l'auteur
  def works_ids
    @works_ids ||= user.get_var(:works_ids, Array::new)
  end

  def table_travaux
    @table_travaux ||= User::table_works
  end

  # ---------------------------------------------------------------------
  #   Méthodes pour les PANNEAUX
  #
  # Cf. plus bas les méthodes pour les onglets
  # ---------------------------------------------------------------------

  # = main =
  #
  # {StringHTML} Retourne le code HTML pour l'onglet
  # courant (current_onglet)
  def panneau_courant
    (data_onglet[:plain_titre]||data_onglet[:titre]).in_h3 +
    Vue::new(current_onglet.to_s, folder_panneaux, self).output
  end

  # {StringHTML} Return le code HTML pour les formulaires de la
  # rangée de définition du partage. Mis dans un helper ici pour
  # être utilisé notamment dans le panneau "Projet" et dans le
  # panneau "Préférences"
  def row_form_sharing
    form.field_select("Partage", 'pref_sharing', user.preference(:sharing), {values: Unan::SHARINGS, warning: (user.projet.sharing == 0)}) +
    form.field_description("Définissez ici qui peut suivre votre projet, c'est-à-dire consulter votre parcours, vos points, etc.")
  end

  # {Return un texte si des données sont manquantes pour la cible ou
  # autre texte qui pointe du doigt un problème (on pourrait d'ailleurs
  # peut-être changer le nom car ce ne sera pas toujours des données manquantes)
  # {String|Nil} RETURN NIL ou le texte indiquant le problème, par exemple
  # les données manquantes.
  # Chaque panneau (i.e. chaque module de panneau) possède sa propre méthode
  # qui est appelée quand le panneau est appelé.
  # @usage dans la vue
  #   <% if missing_data %>
  #     <p>... Des données manquent <%= missing_data(<:target>) %> ..</p>
  #   <% end %>
  # def missing_data
  # end


  # Bouton submit
  # Pour avoir une cohérence entre les panneaux
  # @usage    bureau.submit_button
  def submit_button name = "Enregistrer", options = nil
    if options.nil?
      @submit_button ||= begin
        subbtn = form.submit_button(name)
        subbtn.sub!(/class="btn"/, 'class="btn tiny tres discret"')
      end
    else
      css = ['btn']
      css << 'tiny' unless options[:tiny] === false
      css << 'tres' unless options[:tres_discret] === false
      css << 'discret' unless options[:tres_discret] === false || options[:discret] === false
      subbtn = form.submit_button(name)
      subbtn.sub!(/class="btn"/, "class=\"#{css.join(' ')}\"")
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes pour les ONGLETS
  # ---------------------------------------------------------------------

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

  # Retourne le code HTML pour l'onglet de données +data+
  def onglet data
    titre_onglet(data).in_a(href:"bureau/home?in=unan&cong=#{data[:id]}").in_li(class: (current_onglet == data[:id] ? 'actif' : nil ))
  end

  # Retourne le titre de l'onglet pour les données d'onglet +data+
  def titre_onglet data
    tit = data[:titre]
    if data[:knombre]
      nb = user.nombre_de(data[:knombre])
      tit << " <span class='nombre'>(#{nb})</span>" if nb > 0
    end
    tit
  end

end #/Bureau
end #/Unan
