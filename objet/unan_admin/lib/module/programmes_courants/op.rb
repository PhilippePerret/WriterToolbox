raise_unless_admin

class UnanAdmin
class << self

  def mettre_en_pause prog
    prog.mettre_en_pause
    flash "Le programme de #{prog.auteur.pseudo} a été mis en pause."
  end

  def sortir_de_pause prog
    prog.sortir_de_pause
    flash "Le programme de #{prog.auteur.pseudo} a été relancé."
  end


end #/<< self
end #/UnanAdmin

def current_program
  @current_program ||= Unan::Program.new(site.route.objet_id)
end

# case param(:op)
# when 'mettre_en_pause'
#   UnanAdmin.mettre_en_pause(current_program)
# when 'sortir_de_pause'
#   UnanAdmin.sortir_de_pause(current_program)
# end
