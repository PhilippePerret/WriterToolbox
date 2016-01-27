# encoding: UTF-8
=begin

  Toutes les méthodes qu'on peut utiliser en faisant :

      forum.sujets.<methode>


=end
class Forum
  def sujets ; @sujets ||= Sujet end

class Sujet
  class << self

    # Méthode d'helper retournant la liste des sujets dans des
    # LI
    def as_list params

      all.collect { |sid, sujet| sujet.as_li }.join('')
    end

  end # << self
end #/Sujet
end #/Forum
