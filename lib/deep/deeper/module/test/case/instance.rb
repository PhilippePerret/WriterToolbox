# encoding: UTF-8

class TestUnsuccessfull < StandardError; end

class SiteHtml
class TestSuite
class Case

  # Instance de la test-method qui invoque ce
  # cas. C'est cette test-méthod qui va recevoir les messages
  attr_reader :tmethod

  # Arguments envoyés
  # Ces arguments définissent tout ce qu'il faut savoir, le résultat
  # "droit", l'inversion demandée (if any) et tous les messages en
  # fonction des cas.
  attr_reader :args

  # {True|False} Résultat de l'estimation
  attr_reader :result


  def initialize tmethod, args
    @tmethod  = tmethod
    @args     = args
  end

  # = main =
  #
  # Évaluation du cas, dispatche le message là où il
  # doit aller. Un succès enregistre le message dans l'instance
  # ATest courante, une failure fait sortir (raise) du test
  # courant.
  def evaluate
    if successfull?
      tmethod.all_messages << [bon_message_success, true]
    else
      tmethod.is_not_a_success
      tmethod.all_messages << [bon_message_failure, false]
      raise TestUnsuccessfull if tmethod.fatal?
    end

  end

  # Le vrai résultat, en fonction du fait que le test est
  # inversé ou non ?
  def successfull?
    @is_successfull ||= (positif == args[:result])
  end

  def bon_message_success
    @bon_message ||= positif ? message_success : message_success_not
  end
  def bon_message_failure
    @bon_message_failure ||= positif ? message_failure : message_failure_not
  end

  def positif             ; @positif              ||= !!args[:positif]      end
  def message_success     ; @message_success      ||= args[:on_success]     end
  def message_success_not ; @message_success_not  ||= args[:on_success_not] end
  def message_failure     ; @message_failure      ||= args[:on_failure]     end
  def message_failure_not ; @message_failure_not  ||= args[:on_failure_not] end


end #/Case
end #/TestSuite
end #/SiteHtml
