# encoding: UTF-8
# encoding: UTF-8
raise_unless_admin

class SiteHtml
class Admin
class Console

  # Le nouveau code qui sera affiché dans la console
  def new_code
    @new_code.join("\n") + "\n"
  end

  # Une ligne à ajouter au code exécuté, qui sera remis dans
  # la console
  def add_code line
    @new_code << line
  end
  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  def init
    @messages = Array::new
    @new_code = Array::new
    return self
  end

  # Return false si la console est vide ou espace/retour
  def has_code?
    code != nil
  end

  # Les lignes de code comme un Array qui ne contient aucune
  # ligne vide ni aucun commentaire
  def lines
    @lines ||= begin
      code.gsub(/\r/,'').split("\n").collect do |line|
        line.strip!
        next nil if line == "" || line.start_with?('#')
        line
      end.compact
    end
  end

  # Le code épuré au début et à la fin
  def code
    @code ||= param(:console).nil_if_empty
  end

  # Enregistrer un message pour la sortie des opérations
  def log mess, css = nil
    debug "-> log #{mess}"
    @messages << mess.in_div(class: css.to_s)
    debug "@messages : #{@messages.join}"
  end

  # Sortie pour afficher le résultat des opérations
  def output
    return "" # on ne retourne plus rien pour le moment
    "Résultat de l'opération".in_h3 +
    @messages.join('')
  end


end #/Console
end #/Admin
end #/SiteHtml
