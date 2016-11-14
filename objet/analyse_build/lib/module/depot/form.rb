# encoding: UTF-8
class Analyse
class Depot
class << self

  # Formulaire pour déposer tous les fichiers d'une analyse, fichier
  # collecte de scène, fichier brins, personnages, etc.
  # Pour chaque fichier on définit son format, entre :
  #   TM      Le format des analyses TextMate
  #   Simple  Le format simple avec un ligne pour information
  #   Yaml    Le format YAML, pas encore utilisé
  #
  def formulaire_depot_fichiers
    (
      'deposer_fichier'.in_hidden(name:'operation') +
      champ_identifiant_film  +
      fields_depot_fichier(:scenes).in_fieldset(legend: 'Collecte des scènes'.in_span(class: 'bold')) +
      fields_depot_fichier(:personnages).in_fieldset(legend: 'Personnages'.in_span(class: 'bold')) +
      fields_depot_fichier(:brins).in_fieldset(legend: 'Brins'.in_span(class: 'bold')) +
      bouton_soumettre
    ).
      in_form(id: 'depot_fichiers', action: 'analyse_build/depot', file: true) +
      explications.in_div(class: 'small')
  end

  # Retourne le code pour déposer un fichier d'analyse quelconque, une
  # collecte, un fichier de brins, de personnages, etc.
  def fields_depot_fichier(type)
    (
      champ_input_fichier(type)     +
      menu_type_fichier(type)
    )
  end


  def menu_type_fichier(type)
    # debug "data_depot : #{data_depot.inspect}"
    (
      'Type du fichier : ' +
      TYPES_FICHIER.in_select(id: 'type_fichier', name: "depot[#{type}][ftype]", selected: data_depot[type][:ftype]) +
      ' (1)'.in_span(class: 'small')
    ).in_p
  end

  def champ_input_fichier(type)
    (
      ''.in_input_file(name: "depot[#{type}][fichier]")
    ).in_p
  end

  def champ_identifiant_film
    (
      'Identifiant du film ' +
      data_depot[:film].to_s.in_input_text(name: 'depot[film]', id: 'depot_film') +
      ' (2)'.in_span(class: 'small')
    ).in_p
  end

  def bouton_soumettre
    (
      'Déposer les fichiers'.in_submit
    ).in_div(class: 'buttons right')
  end

  def explications
    lien_explication_formats = 'cette page'.in_a(href: 'analyse_build/formats')
    <<-HTML
    <p>
      (1) Bien définir le type du fichier pour qu'il soit parsé correctement. Vous pouvez trouver l'explication des formats dans le manuel ou sur #{lien_explication_formats}.
    </p>
    <p>
      (2) C'est l'identifiant numérique du film. Pour l'obtenir, il suffit d'afficher sa fiche dans le filmodico et de relever le numéro dans l'URL entre `filmodico` et `show`. Par exemple, si l'url est `filmodico/23/show`, l'identifiant du film est 23).
    </p>
    HTML
  end
end #/<< self
end#Depot
end#Analyse
