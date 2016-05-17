# encoding: UTF-8
class DSLTestMethod

  # Le libellé complet, tel qu'il apparaitra dans le rapport final
  # affiché, avec le numéro de file-test et de test-case.
  def full_libelle_output ifile, icase
    "#{ifile}.#{icase} - #{libelle}".in_div(class:'tlib')
  end

  # Sortie des messages
  def messages_output
    all_messages.collect do |dmess|
      # Ci-dessous, ne pas mélanger le `is_suc`, qui concerne le
      # message lui-même, donc le résultat d'un seul "case-test" du
      # test-méthode, avec le `success?` qui concerne tout le
      # test-méthode.
      mess, is_suc = dmess
      "#{is_suc ? '•' : '#'} #{mess}".in_div(class:"tcase #{is_suc ? 'suc' : 'fai'}")
    end.join('').in_div(class:"#{success? ? 'suc' : 'fai'}")
  end

  # Le libellé pour la sortie
  def libelle
    @libelle ||= begin
      ddef = description_defaut + (fatal? ? '' : ' NON FATAL')
      if description.nil_if_empty != nil
        description + ddef.in_div(class:'defname')
      else
        ddef
      end
    end
  end



end
