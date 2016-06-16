# encoding: UTF-8
=begin

  Concernant la propriété `specs` enregistré dans la table

=end
class Unan
class Projet

  # Bit 1   Type du projet (Unan::Projet::TYPES)
  # Bit 2   - pour développement ultérieur -
  # Bit 3   - pour développement ultérieur -
  def specs
    @specs ||= get(:specs)
  end


end #/Projet
end #/Unan
