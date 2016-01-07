# encoding: UTF-8

# Barrière absolue
# Il est impossible d'atteindre toutes ces parties sans être un
# administrateur. Noter qu'il suffit de mettre cette barrière ici
# pour qu'elle fonctionne pour toutes les parties de unan_admin.
raise_unless_admin

class UnanAdmin
  class << self
    def bind; binding() end
  end
end
