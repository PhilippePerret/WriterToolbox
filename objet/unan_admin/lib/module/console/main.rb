# encoding: UTF-8
class Console
  include Singleton

  # = main =
  #
  # Méthode principale qui joue le code entré en console
  #
  def run
    code != nil || begin
      flash 'Aucun code à jouer.'
      return
    end
    case code
    when /^new page narration /
      args = code.sub(/^new page narration /, '').strip
      pid, pday = args.split(' ')
      require_procedure('new_page_narration', {page_id: pid, pday: pday})
    end
  end

  # Pour ajouter des messages en sortie
  # 
  def add_message mess
    @output ||= []
    case mess
    when Array  then @output += mess
    when String then @output << mess
    else raise("Je ne sais pas traiter le type #{mess.class} dans l'output.")
    end
  end

  # = main =
  #
  # Retour le texte à écrire en retour
  def output
    (@output || []).join("<br>")
  end

  # Le code complet et épuré envoyé dans la console
  def code
    @code ||= param(:console).strip.nil_if_empty
  end

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  # Requiert la procédure
  #
  # Note : le fichier doit avoir le même nom que la méthode
  def require_procedure proc, args = nil
    (folder_procedure + "#{proc}.rb").require
    send(proc.to_sym, args)
  end
  def folder_procedure
    @folder_procedure ||= UnanAdmin.folder_modules + 'console_procedure'
  end
end
