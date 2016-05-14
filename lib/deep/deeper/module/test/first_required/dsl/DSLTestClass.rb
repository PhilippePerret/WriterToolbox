# encoding: UTF-8
=begin

Ouvrir le fichier Test/Implémentation/DSLTestClass.md pour obtenir
tous les détails

=end
class DSLTestClass

  # Instanciation commune à toutes les méthode de test
  def initialize &block
    instance_eval(&block) if block_given?
    init
  end

  # Initialisation de la méthode de test
  def init
    # Les données du test
    @tdata = Hash::new
    @tdata = {
      start_time:           Time.now,
      end_time:             nil,
      description:          "",
      description_defaut:   nil
    }
    if self.respond_to?(:description_defaut)
      @tdata.merge!(description_defaut: description_defaut)
    end
  end

  # Description précise du du test
  def description str
    @tdata[:description] = str
  end

  def atest

  end

  def html
    @html ||= ""
  end
  def body
    @boday ||= ""
  end
  def head
    @head ||= ""
  end

end
