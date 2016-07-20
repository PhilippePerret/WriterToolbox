# encoding: UTF-8
=begin

  Module contenant les définitions pour le module principal quiz

=end
site.require_module 'quiz'
class ::Quiz

  # Pour définir la database (elle aura pour nom final :
  # `boite-a-outils_quiz_biblio`)
  #
  def prefix_base
    @prefix_base ||= 'biblio'
  end
end
