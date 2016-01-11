# encoding: UTF-8

class UnanAdmin

  class << self

    # Données pour un menu select des types de projet
    def types_projets_for_select
      @types_projets_for_select ||= begin
        Unan::TYPES_PROJETS.collect { |wtype, dtype| [ wtype, dtype[:hname] ] }
      end
    end

    # {StringHTML} Return le code HTML pour tous les menus qui
    # constituent la données 'type_resultat' (à la base pour une
    # étape) déterminant le type du résultat attendu, de façon
    # informatique.
    # BIT 1       Support : document, plan, image, etc.
    # BIT 2       Destinataire : soi, le monde, producteur, lecteur
    #
    # +prefix+ Le préfixe pour les name et les id.
    def menus_type_resultat prefix
      "Support".in_span + type_resultat_support(prefix) +
      type_resultat_destinataire(prefix) +
      type_resultat_exigence(prefix)
    end
    def type_resultat_support prefix
      Unan::SUPPORTS_RESULTAT
      .in_select(name: "#{prefix}[support_tres]", id: "#{prefix}_support_tres")
    end
    def type_resultat_destinataire prefix
      Unan::DESTINATAIRES.in_select(name:"#{prefix}[destinataire_tres]", id:"#{prefix}_destinataire_tres")
    end
    def type_resultat_exigence prefix
      Unan::NIVEAU_DEVELOPPEMENT.in_select(name:"#{prefix}[exigence_tres]", id:"#{prefix}_exigence_tres")
    end

    # {StringHTML} Return le code HTML du menu/sous-menu des sujets et
    # sous-sujets cibles
    # +for_id+ Le nom principal du span contenant le menu des sujets-cibles
    # Le sujet-cible choisi sera placé dans un champ hidden d'id et de name
    # "<for_id>_value".
    def menu_sujets_cibles options = nil
      options ||= Hash::new
      options[:id]    ||= 'youpi'
      options[:name]  ||= 'youpi'

      value = options.delete(:value)
      hvalue = if value.nil?
        ""
      else
        # Il y a une valeur
        # => Il faut la mettre telle quelle dans le champ hidden et
        # reconstituer sa donnée humaine pour la mettre dans le span
        sujet     = value[0].to_i.freeze
        subsujet  = value[1].to_i.freeze
        data_sujet = SUJETS_CIBLES.values[sujet]
        debug "data_sujet: #{data_sujet.inspect}"
        hval = data_sujet[:hname] + "::"
        data_sujet[:sub].each do |k, dk|
          if dk[:value] == subsujet
            hval << dk[:hname]
            break # on a trouvé le sous-sujet
          end
        end
        hval
      end

      if false == path_fichier_html.exist? || path_fichier_html.mtime < path_fichier_data.mtime
        update_menu_sujets_cibles
      end
      (
        hvalue.in_span(class:'sujet_human_value', id: "#{options[:id]}_human") + # pour afficher la valeur humaine
        path_fichier_html.read.sub(/__HIDDEN_FIELD_ID__/, options[:id]) +
        value.to_s.in_hidden(name: options[:name], id: options[:id])
      )
      .in_span(class:'conteneur_menu_sujets')
    end

    # Le fichier qui contient le code du menu HTML construit à partir des
    # données du fichier suivant. Il permet de ne pas avoir à le reconstruire
    # chaque fois (c'est un gros menu)
    def path_fichier_html
      @path_fichier_html ||= site.folder_objet + '/unan_admin/lib/html/menu_sujets_cibles.html'
    end

    # Fichier des données de sujets cibles.
    # Dès que ce fichier est modifié, le code du fichier précédent est
    # automatiquement actualisé pour que toutes les données soient prises
    # en compte.
    def path_fichier_data
      @path_fichier_data ||= Unan::folder_data + 'sujets_cibles.rb'
    end

    # Actualisation du menu des sujets cibles
    # Note: RETURN le code formé après l'avoir enregistré
    def update_menu_sujets_cibles
      require path_fichier_data # => SUJETS_CIBLES
      code_html = "<ul class='sujets_cibles' hidden-field-id='__HIDDEN_FIELD_ID__'>\n" +
        SUJETS_CIBLES.collect do |sujet, dsujet|
        (
          dsujet[:hname].in_span(class:'item_name') +
          "\n\t<ul class='sub_sujets_cibles'>" + dsujet[:sub].collect do |sub, dsub|
            dsub[:hname].in_li('sujet-value' => dsujet[:value], value: dsub[:value], class:'subitem')
          end.join("\n\t") + '</ul>'
        ).in_li(class:'item')
      end.join("\n") + "\n</ul>"
      # On écrit le code dans le fichier
      path_fichier_html.write code_html
      return code_html
    end
  end
end
