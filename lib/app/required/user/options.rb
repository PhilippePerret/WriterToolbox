# encoding: UTF-8
=begin

  Les bits d'options de 0 à 15 sont réservés à l'administration
  et les bits de 16 à 31 sont réservés à l'application elle-même.

  C'est ici qu'on définit ces options propres à l'application.

=end
class User

  # Bit 32 des options (index 31)
  # Si 1, l'user est un icarien
  # Si 2, l'user est un icarien actif
  def bit_icarien
    (options||"")[31].to_i
  end

  def icarien?
    bit_icarien > 0
  end
  def icarien_actif?
    bit_icarien == 2
  end


  # Index d'options : 1
  # -------------------
  # {Fixnum} Grade forum de l'user (0 à 9)
  def grade ; @grade ||= get_option(:grade) end
  def set_grade new_grade ; set_option(:grade, new_grade) end


end
