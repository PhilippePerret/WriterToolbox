# encoding: UTF-8
class SuperFile

  # Traitement en fonction du fichier YAML
  def yaml_content_by_type

    case affixe
    when 'structure'
      traite_content_as_structure
    when 'fondamentales'
      traite_content_as_fondamentales
    else
      # Traitement comme une liste de choses, par exemple comme une
      # liste d'ironies dramatiques ou de préparations-paiements
      traite_content_as_list_of_things
    end
  end

  # Traitement le contenu yam comme une liste de choses
  def traite_content_as_list_of_things
    "[LISTE DE CHOSES]"
  end

  # Traitement du fichier yaml structure.yaml contenant la
  # définition de la structure du film
  def traite_content_as_structure
    "[STRUCTURE DU FILM]"
  end

  def description_in h
    (
      "Description".in_span(class:'libelle') +
      h[:description].in_span(class:'value')
    ).in_div(class:'row')
  end
  def traite_content_as_fondamentales
    fd1 = yaml_content[:personnage_fondamental]

    <<-HTML
<dl>
  <dt>Personnage Fondamental (Fd. 1)</dt>
  <dd>
    <div class="row">
      <span class="libelle">Nom</span>
      <span class="value">#{fd1[:nom]}</span>
    </div>
    #{description_in(fd1)}
  </dd>

  <dt>Question Dramatique Fondamentale (Fd. 2)</dt>
  <dd>
  </dd>

  <dt>Opposition Fondamentale (Fd. 3)</dt>
  <dd>
  </dd>

  <dt>Réponse Dramatique Fondamentale (Fd. 4)</dt>
  <dd>
  </dd>

  <dt>Concept Fondamental</dt>
  <dd>
  </dd>
</dl>
    HTML
  end
end #/SuperFile
