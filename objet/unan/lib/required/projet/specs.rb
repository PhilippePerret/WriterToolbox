# encoding: UTF-8
=begin

  Concernant la propriété `specs` enregistré dans la table

=end
class Unan
class Projet

  # Bit 1   Type du projet (Unan::Projet::TYPES)
  # Bit 2   - pour développement ultérieur -
  # Bit 3   - pour développement ultérieur -
  # Bit 4-5-6   Nombre pages
  def specs
    @specs ||= get(:specs)
  end

  def nombre_pages
    @nombre_pages ||= (specs||'').ljust(6,'0')[3..5].to_i.nil_if_zero
  end
  def nombre_pages= value
    new_specs = (specs || '').ljust(6,'0')
    new_specs[3..5] = (value.to_s).rjust(3,'0')
    @nombre_pages = value
    set(:specs => new_specs)
  end


end #/Projet
end #/Unan
