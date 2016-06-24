# encoding: UTF-8
=begin
Noter que c'est un singleton et que la méthode `bureau` le renvoie.
Donc toutes les méthodes de ce module peuvent être appelées de n'importe
où par :
    bureau.<methode> ...
=end
# Beaucoup de formulaires dans ce bureau
Unan::require_module 'bureau'

unless user.identified? && user.unanunscript?
  # Ça peut arriver par exemple lorsque l'user règle ses préférences
  # après login sur cette page, sans savoir ce que c'est.
  # Ça doit pouvoir arriver aussi quand on vient d'un lien dans
  # un mail.
  redirect_to 'unan/home'
end

class Unan
class Bureau

  # Pour le moment
  # Plus tard, permettra de visiter des bureaux en tant
  # qu'administrateur
  def auteur= u;  @auteur = u       end
  def auteur;     @auteur ||= user  end

  # Le jour-program courant
  # @usage      bureau.pday
  def pday
    @pday ||= auteur.program.current_pday
  end
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
    @works ||= begin
      # works_ids.collect { |wid| Unan::Program::Work::new(user.program, wid) }
      []
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes pour les PANNEAUX
  #
  # Cf. plus bas les méthodes pour les onglets
  # ---------------------------------------------------------------------

  # = main =
  #
  # {StringHTML} Retourne le code HTML pour l'onglet
  # courant
  def panneau_courant ; Onglet::current.panneau end

  # Route pour conduire au panneau courant
  # @usage : href: route_to_this
  def route_to_this
    @route_to_this ||= "bureau/home?in=unan&cong=#{Onglet::current.id}"
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

  # ---------------------------------------------------------------------
  #
  #   Méthodes pour les ONGLETS
  #
  # ---------------------------------------------------------------------

  # {StringHTML} Retourne le code HTML de la barre
  # d'onglets
  def bande_onglets ; Onglet::bande end


  class Onglet

    # Onglets du bureau Un An Un Script d'un user suivant le programme
    ONGLETS = {
      state:        {id: :state,        titre:"État",     plain_titre: "État général du programme"},
      projet:       {id: :projet,       titre:"Projet"},
      taches:       {id: :taches,       titre:"Tâches",   knombre: :task},
      pages_cours:  {id: :pages_cours,  titre:"Cours",    knombre: :page},
      forum:        {id: :forum,        titre:"Forum",    knombre: :forum},
      quiz:         {id: :quiz,         titre:"Quiz",     knombre: :quiz},
      preferences:  {id: :preferences,  titre:"Préférences"},
      aide:         {id: :aide,         titre:"Aide"}
    }

    # ---------------------------------------------------------------------
    #   Classe
    # ---------------------------------------------------------------------
    class << self

      # Retourne le code HTML de la bande d'onglets
      def bande
        ONGLETS.keys.collect do |ong_id|
          new(ong_id).onglet# + (ong_id == :aide ? '<br />' : '')
        end.join.in_ul(id:'bande_onglets')
      end

      # {Unan::Bureau::Onglet} Return l'instance Onglet
      # de l'onglet courant.
      def current
        @current ||= new((param(:cong) || :state).to_sym)
      end

    end # << self

    # ---------------------------------------------------------------------
    #   INSTANCES
    # ---------------------------------------------------------------------
    # {Symbol} Identifiant de l'onglet, par exemple :forum
    attr_reader :id
    def initialize onglet_id
      @id = onglet_id
    end

    # {StringHTML} Retourne le code HTML de l'onglet
    # en tant qu'onglet
    def onglet
      # return "#{id}"
      titre_onglet.
        in_li(class: class_onglet).
        in_a(href:"bureau/home?in=unan&cong=#{id}")
    end
    # {StringHTML} Retourne le code HTML du panneau
    # complet de l'onglet.
    # Note : Utilisé seulement pour l'onglet courant
    def panneau
      @panneau ||= begin
        Onglet::current.titre_panneau +
        Vue::new(id.to_s, bureau.folder_panneaux, bureau).output
      end
    end


    # Retourne le titre en fonction du fait qu'il y a
    # ou nom des travaux dans cet onglet
    def titre_onglet
      @titre_onglet ||= begin
        data[:titre] + nombre_travaux_human
      end
    end

    def nombre_travaux_human
      return '' unless has_travaux?
      css = ['nombre']
      css << 'warning bold' if has_travaux_to_start?
      " (#{nombre_travaux})".in_span(class:css.join(' '))
    end

    def titre_panneau
      @titre_panneau ||= (data[:plain_titre]||data[:titre]).in_h3
    end

    def class_onglet
      @class_onglet ||= begin
        css = Array::new
        css << 'exergue'  if has_travaux?
        css << 'actif'    if current?
        css.join(' ').nil_if_empty
      end
    end

    # Return true si l'onglet est l'onglet courant
    def current?
      @is_current ||= self.class.current.id == id
    end
    def has_travaux?
      @has_travaux ||= (nombre_travaux > 0)
    end
    def has_travaux_to_start?
      @has_travaux_ot_start ||= begin
        bureau.current_pday.nombre_tostart_of_type( data[:knombre] ) > 0
      end
    end
    # Si des travaux sont à démarrer, le nombre est mis
    # en rouge.
    def nombre_travaux
      @nombre_travaux ||= begin
        if data[:knombre].nil?
          0
        else
          user.nombre_de(data[:knombre])
        end
      end
    end

    # Données de l'onglet (dans ONGLETS)
    def data
      @data ||= ONGLETS[id]
    end
  end #/Onglet

end #/Bureau
end #/Unan
