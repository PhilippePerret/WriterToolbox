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
    c += success_messages.collect do |mess|
      mess.in_div(class:'suc')
    end.join('')
    c += failure_messages.collect do |mess|
      mess.in_div(class:'err')
    end.join('')
    c.in_div(class:"#{success? ? 'suc' : 'err'}")
  end


  def libelle
    description || description_defaut
  end



end
