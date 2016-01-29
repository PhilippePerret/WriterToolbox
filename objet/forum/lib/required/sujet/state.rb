# encoding: UTF-8
=begin
Extention de Forum::Post pour les états
=end
class Forum
class Sujet

  # Return true si le sujet a été validé et peut apparaitre
  # dans la liste
  def valid?
    bit_validation == 1
  end

end #/Sujet
end #/Forum
