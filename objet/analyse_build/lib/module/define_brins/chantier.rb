# encoding: UTF-8
=begin

Extension de la classe AnalyseBuild pour la définition des brins

=end
class AnalyseBuild

  def form_define_brins
    (
      'set_define_brins'.in_hidden(name: 'operation') +
      brins_as_choosable_list   +
      scenes_and_paragraphes_as_list_containers +
      explication_define_brins  +
      bouton_soumettre_new_brins
    ).in_form(id:'form_define_brins', action: "analyse_build/#{film.id}/define_brins")
  end
  # Liste des scènes prêtes à définir les brins
  # Chaque div contient un champ hidden qui consigne la liste des
  # brins de la scène. Ce champ est incrémenté dès qu'on glisse un
  # brin sur une scène.
  def scenes_and_paragraphes_as_list_containers
    scenes.collect do |hscene|

      hscene[:brins] ||= Array.new

      div_scene(hscene) +
      hscene[:data_paragraphes].collect do |dparagraphe|
        div_paragraphe(dparagraphe)
      end.join('')

    end.join.in_div(id: 'scenes_et_paragraphes')
  end

  def div_scene hscene
    scene_id = hscene[:numero]
    hidden_file_id = "scene-#{scene_id}-brins"
    (
      hscene[:brins].join(' ').in_span(id:"scene-#{scene_id}-spanbrins", class:'span_brins')+
      hscene[:resume] +
      hscene[:brins].join(' ').in_hidden(id: hidden_file_id, name: hidden_file_id)
    ).in_div(class: 'scene contbrins', id: "scene-#{scene_id}")
  end
  def div_paragraphe hpara
    para_id = hpara[:id].sub(/:/,'_')
    hidden_file_id = "paragraphe-#{para_id}-brins"
    (
      hpara[:brins].join(' ').in_span(id:"paragraphe-#{para_id}-spanbrins", class:'span_brins')+
      hpara[:texte] +
      hpara[:brins].join(' ').in_hidden(id: hidden_file_id, name: hidden_file_id)
    ).in_div(class: 'parag contbrins', id: "paragraphe-#{para_id}")
  end

  # La liste des brins, comme une liste qu'on peut choisir et
  # glisser sur les scènes.
  def brins_as_choosable_list
    brins.collect do |bid, hbrin|
      "#{hbrin[:id]} #{hbrin[:titre]}".in_div(class: 'brin', id: "brin-#{hbrin[:id]}")
    end.join.in_div(id: 'brins')
  end

  def explication_define_brins
    t = <<-HTML
    Cette édition permet de re-définir les brins pour les affiner.
    Cliquer sur une scène pour voir mieux la liste des brins (texte).
    À l'enregistrement, les données fournies seront modifiées et l'on pourra même recharger un fichier de collecte actualisé avec les nouveaux brins.
    HTML
    t.in_div(class: 'small italic')
  end

  def bouton_soumettre_new_brins
    'Enregistrer'.in_submit(class:'btn').in_div(class: 'right btns')
  end

end #/AnalyseBuild
