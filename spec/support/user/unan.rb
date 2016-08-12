# encoding: UTF-8

def remove_all_programs_unan verbose = true
  site.require_objet 'unan'
  nombre = 0
  Unan.table_programs.select.collect{|h| h[:auteur_id]}.each do |uid|
    User.new(uid).test_destroy_from_unan
    nombre += 1
  end
  verbose && puts("Destruction de tous les programmes UN AN (#{nombre}).")
end

class User
  def reset_program
    @program = Unan::Program.new(program.id)
  end
  def reset_projet
    @projet = nil
  end
end #/User
