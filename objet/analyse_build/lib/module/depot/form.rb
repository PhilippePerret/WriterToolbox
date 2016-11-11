# encoding: UTF-8
class Analyse
class Depot
class << self

  # Retourne le code pour déposer un fichier d'analyse quelconque, une
  # collecte, un fichier de brins, de personnages, etc.
  def formulaire_depot_fichier
    (
      'deposer_fichier'.in_hidden(name:'operation') +
      champ_input_fichier     +
      menu_type_fichier       +
      champ_identifiant_film  +
      bouton_soumettre
    ).
      in_form(id: 'depot_fichier', action: 'analyse_build/depot', file: true).
      in_fieldset(legend: 'Dépôt de fichier d’analyse') +
      explications.in_div(class: 'small')
  end


  def menu_type_fichier
    (
      'Type du fichier : ' +
      TYPES_FICHIER.in_select(id: 'type_fichier', name: 'depot[ftype]', selected: data_depot[:ftype]) +
      ' (1)'.in_span(class: 'small')
    ).in_p
  end

  def champ_input_fichier
    (
      ''.in_input_file(name: 'depot[fichier]')
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
      'Déposer le fichier'.in_submit
    ).in_div(class: 'buttons right')
  end

  def explications
    lien_explication_formats = 'cette page'.in_a(href: 'analyse_build/formats')
    <<-HTML
    <p>
      (1) Bien définir le type du fichier pour qu'il soit parsé correctement. Vous pouvez trouver l'explication des formats dans le manuel ou sur #{lien_explication_formats}.
    </p>
    <p>
      (2) Vous pouvez indiquer le film de plusieurs façons : <ol>
        <li>avec l'identifiant numérique (afficher sa fiche dans le filmodico et relever le numéro dans l'URL entre `filmodico` et `show`. Par exemple, si l'url est `filmodico/23/show`, l'identifiant du film est 23),</li>
        <li>avec l'identifiant TITRE+ANNÉE, par exemple `Her2013`,</li>
        <li>en fournissant un nouveau nom si le film n'est pas encore dans le filmodico. Mais pour ce faire, vous devez avoir le grade d'un super analyste.</li>
      </ol>
    </p>
    HTML
  end
end #/<< self
end#Depot
end#Analyse
