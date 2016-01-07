# encoding: UTF-8
raise "Section interdite" unless user.admin?
class SiteHtml
class Admin
class Console

  def execute_code

    lines.each do |line|

      # On marque la ligne pour pouvoir savoir ce qui a produit
      # le résultat
      log line, :code

      # On ajoute toujours la ligne au code qui sera ré-affiché dans
      # la console
      add_code line

      #
      # DÈS QU'UNE LIGNE EST AJOUTÉE, IL FAUT RENSEIGNER
      # LE FICHIER help.rb DE CONSOLE
      #
      add_code "#\n# => " + case line

      when "vide table paiements", "vider table paiements"

        vide_table_paiements

      when "remove table paiements"

        remove_table_paiements

      else
        # Dans le cas où la ligne n'a pas pu être interprétée avant,
        # on essaie de l'exécuter telle quelle
        begin
          res = eval(line)
          "#{res.inspect}"
          # log "---> #{res.inspect}"
        rescue Exception => e
          error "Line injouable : `#{line}`"
          "### LIGNE INCOMPRÉHENSIBLE ### #{e.message}"
        end
      end + "\n#"

    end

  end

  # ---------------------------------------------------------------------
  #   Méthodes utilisables
  # ---------------------------------------------------------------------
  def vide_table_paiements

    if OFFLINE
      User::table_paiements.pour_away
      if User::table_paiements.count == 0
        "Table des paiements vidée avec succès"
      else
        "Bizarrement, la table des paiements ne semble pas vide…"
      end
    else
      "Impossible de vider la table des paiements en ONLINE"
    end

  end

  def remove_table_paiements
    if OFFLINE
      User::table_paiements.remove
      "Table des paiements détruite avec succès."
    else
      "Impossible de détruire la table des paiements en ONLINE. On perdrait toutes les données."
    end
  end

  def montre_table table_ref

    db_name, table_name = table_ref.split('.')

  end

end #/Console
end #/Admin
end #/SiteHtml
