# encoding: UTF-8

# Barrière absolue
# Il est impossible d'atteindre toutes ces parties sans être un
# administrateur. Noter qu'il suffit de mettre cette barrière ici
# pour qu'elle fonctionne pour toutes les parties de unan_admin.
raise_unless_admin

class UnanAdmin
  extend MethodesMainObjet
class << self

  # # Requiert le dossier +module_name+ qui se trouve dans le dossier
  # # module d'Unan-Admin (./objet/unan_admin/lib/module)
  # # OBSOLÈTE : C'est une méthode commune maintenant
  # def r e q uire_module module_name
  #   (folder_modules + module_name).require
  # end

  def bind; binding() end

end # << self
end #/UnanAdmin
