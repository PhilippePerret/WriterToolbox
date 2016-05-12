# encoding: UTF-8

class SiteHtml
class TestSuite
class Case

  class << self
    # Le ATest courant (SiteHtml::TestSuite::File::ATest) qui
    # doit recevoir les messages de succès
    attr_accessor :current_atest
  end #/<< self

  # Arguments envoyés
  attr_reader :args

  # {True|False} Résultat de l'estimation
  attr_reader :result



  def initialize args
    @args = args
    # debug "args: #{args.inspect}"
    # debug " => successfull? = #{successfull?.inspect}"
  end

  # = main =
  #
  # Évaluation du cas, dispatche le message là où il
  # doit aller. Un succès enregistre le message dans l'instance
  # ATest courante, une failure fait sortir (raise) du test
  # courant.
  def evaluate
    if successfull?
      self.class::current_atest.add_success bon_message_success
    else
      raise bon_message_failure
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
