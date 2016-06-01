# encoding: UTF-8
class SiteHtml

  # Exécute le script +script+ (qui doit être au format AppleScript)
  # RETURN False s'il y a eu une erreur (qui est affichée) ou
  # le retour du script qui peut contenir l'erreur AppleScript.
  def osascript(script)
    File.open("./.scriptprov.scpt",'wb'){|f| f.write(script)}
    res = `osascript ./.scriptprov.scpt 2>&1`
  rescue Exception => e
    error "# ERREUR : #{e.message}"
  else
    res
  ensure
    File.unlink("./.scriptprov.scpt")
  end


  # Ajoute une actualisation dans la table site_cold.updates
  #
  # Cet ajout peut se faire de façon automatique ou par la
  # console.
  #
  # @syntaxe    site.new_update( data )
  # Pour les données, cf. le manuel
  def new_update data
    require_module 'updates'
    SiteHtml::Updates.new_update data
  end
end #/SiteHtml
