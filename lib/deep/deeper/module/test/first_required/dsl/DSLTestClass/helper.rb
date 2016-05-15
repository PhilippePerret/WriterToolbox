# encoding: UTF-8
class DSLTestClass

  # Le libellé complet, tel qu'il apparaitra dans le rapport final
  # affiché, avec le numéro de file-test et de test-case.
  def full_libelle_output ifile, icase
    "#{ifile}.#{icase} - #{libelle}".in_div(class:'tlib')
  end

  # Sortie des messages
  def messages_output
    c = String::new
    c += as_div_list success_messages, 'suc'
    c += as_div_list failure_messages, 'fai'
    c.in_div(class:"#{success? ? 'suc' : 'fai'}")
  end

  # Transforme la liste des messages +liste_mess+ en
  # string de div tcase
  def as_div_list liste_mess, css
    puce = success? ? "•" : "#"
    liste_mess.collect do |mess| "#{puce} #{mess}".in_div(class:"tcase #{css}") end.join('')
  end

  # Le libellé pour la sortie
  def libelle
    if description.nil_if_empty != nil
      description + description_defaut.in_div(class:'defname')
    else
      description_defaut
    end
  end



end
