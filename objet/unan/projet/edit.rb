# encoding: UTF-8
=begin

Extension de la class Unan::Projet pour l'édition

=end
raise_unless_identified
site.require 'form_tools'

class Unan
class Projet

  def edit
    flash "Je dois éditer le projet ##{id}"
  end

end #/Projet
end #/Unan
