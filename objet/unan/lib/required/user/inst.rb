# encoding: UTF-8
class User

  # {Unan::Program} Le programme courant (ou nil)
  def program
    @program ||= Unan::Program::get_current_program_of(self.id)
  end

  # Return TRUE si l'user vient de s'inscrire au programme
  # un an un script

  # RETURN true si l'user suit le programme Un An Un Script
  # On le sait à partir du moment où il possède un programme
  # ACTIF dans la table des programmes
  def unanunscript?
    program.instance_of?(Unan::Program)
  end

  # Le dossier data de l'user dans ./database/data/unan/user/<id>/
  def folder_data
    @folder_data ||= begin
      site.folder_db + "unan/user/#{id}"
    end
  end
end
