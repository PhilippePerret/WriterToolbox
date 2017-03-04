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
    when /^check auteurs?(.*)$/
      c = code.dup
      options = Hash.new
      if c.match(/--repare$/)
        options.merge!(repare: true)
        c = c.sub(/--repare$/,'').strip
        flash "Réparation demandée."
      end
      debug "c = #{c.inspect}"
      if c != 'check auteurs'
        ref_auteur = c.sub(/^check auteur /, '').strip
        options.merge!(ref_auteur: ref_auteur)
      end

      require_procedure('check_auteurs', options)
    end
  end

  # Pour ajouter des messages en sortie
  #
  # @usage:   console.add_message <le message ou la liste>
  # Alternative:
  #           console.output <message ou array de message>
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
  def output mess = nil
    if mess.nil?
      (@output || []).join("<br>")
    else
      add_message mess
    end
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
