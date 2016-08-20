# encoding: UTF-8
class Unan
class Projet

  # Type humain, par exemple "Roman" ou "Projet" (noter la majuscule)
  def type_humain
    @type_humain ||= Unan::Projet::TYPES[type][:shorthname]
  end

end #/Projet
end #/Unan
