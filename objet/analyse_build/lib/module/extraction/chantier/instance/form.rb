# encoding: UTF-8
class AnalyseBuild

  # Return le code HTML pour le formulaire définissant les choses à
  # extraire du film courant.
  #
  # C'est dans ce formulaire que se définit ce qu'il faut extraire des
  # données déposées et exploitées. Un fichier est produit, contenant
  # l'élément spécifié, par exemple un évènemencier sans horloge et
  # sans timeline, allant du temps 0:30 au temps 4:30.
  #
  def extract_form
    site.require 'form_tools'
    form.prefix = 'thing'
    (
      'extraire'.in_hidden(name: 'operation')+
      form.field_select('Type d’extraction', 'type', nil, {values: AnalyseBuild::Thing::DATA_THINGS, onchange: 'apercu()'}) +
      form.field_raw('Laps', 'laps', nil, {field: menus_from_time_to_time}) +
      form.field_raw('Numéro', 'numero', nil, {field: fields_pour_numero}) +
      form.field_raw('Format', 'format', nil, {field: fields_for_format}) +
      'Extraire'.in_submit.in_div(class: 'buttons')
    ).in_form(id: 'extract_form', class: 'dim2080', action: "analyse_build/#{film.id}/extract")
  end

  # Return les deux champs pour choisir le temps de départ et le temps de fin
  def menus_from_time_to_time
    'de' +
    '0:00:00'.in_input_text(class: 'medium', name: 'thing[from_time]', id: 'thing_from_time', onchange: 'apercu()')+
    'à' +
    'FIN'.in_input_text(class: 'medium', name: 'thing[to_time]', id: 'thing_to_time', onchange: 'apercu()')
  end

  def fields_pour_numero
    'Numero'.in_checkbox(name: 'thing[with_numero]',  id: 'thing_with_numero',  onclick: 'apercu()') +
    ' Avant : ' + [['',''], ['Scène ', 'Scène '], ['Sc. ', 'Sc. ']].in_select(name: 'thing[avant_numero]', id: 'thing_avant_numero', onclick: 'apercu()') +
    ' Après : ' + [['',''], ['.','.'], [' :', ' :']].in_select(name: 'thing[apres_numero]', id: 'thing_apres_numero', onclick: 'apercu()')

  end
  # Les champs qui permettent de définir le format de sortie
  def fields_for_format
    'Horloge'       .in_checkbox(name: 'thing[with_horloge]', id: 'thing_with_horloge', onclick: 'apercu()') +
    'Durée'         .in_checkbox(name: 'thing[with_duree]',   id: 'thing_with_duree',   onclick: 'apercu()') +
    'Lieu (Ext/Int)'.in_checkbox(name: 'thing[with_lieu]',    id: 'thing_with_lieu',    onclick: 'apercu()') +
    'Effet'         .in_checkbox(name: 'thing[with_effet]',   id: 'thing_with_effet',   onclick: 'apercu()') +
    'Décor'         .in_checkbox(name: 'thing[with_decor]',   id: 'thing_with_decor',   onclick: 'apercu()')
  end

end #/AnalyseBuild
