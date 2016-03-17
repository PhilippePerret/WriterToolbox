# encoding: UTF-8
raise_unless_admin
raise "Section interdite" unless user.admin?

class SiteHtml
class Admin
class Console
  #
  # AIDE
  #
  # À REMPLIR À MESURE QUE DES MÉTHODES S'AJOUTENT
  #
  def help
    require 'yaml'
    # Le code total construit
    c = String::new
    # Pour incrémenter les parties fermées
    @iclosedpart = 1
    # On traite l'aide commune à tous les RestSite
    c << "Aide propre aux sites RestSite".in_h3(class:'underline')
    c << mise_en_forme_aide( _("help.yml") )
    # On traite l'aide propre à l'application courante
    c << "Aide propre à l'application".in_h3(class:'underline')
    c << mise_en_forme_aide( _("help_app.yml") )

    return c
  end

  # Retourne le code HTML de la mise en forme du
  # fichier d'aide `path` (qui en fait se résume au nom du fichier
  # à la racine de ce même dossier)
  # +iclosepart+ Indice de la partie courante, pour le numérotage des
  # section qui produiront des liens pour les ouvrir/fermer.
  def mise_en_forme_aide path
    iclosepart_init = @iclosedpart.freeze
    c = String::new
    hdata = YAML::load_file( path )
    hdata.each do |haide|
      case haide['type']
      when 'TITLE'
        c << "</dl>" if @iclosedpart > 1
        @iclosedpart += 1
        dl_id = "description_list-#{@iclosedpart}"
        c << "<h4 onclick=\"$('dl##{dl_id}').toggle()\">#{haide['description']}</h4>"
        c << "<dl id=\"#{dl_id}\" class=\"small\" style=\"display:none\">"
      when 'GOTO'
      when 'HELP'
      else
        c << haide['command'].in_dt
        c << haide['description'].in_dd
        c << haide['note'].in_dd(class:'note')      unless haide['note'].nil?
        c << haide['implement'].in_dd(class:'imp')  unless haide['implement'].nil?
      end
    end
    c << "</dl>" if @iclosedpart > iclosepart_init
    return c
  end

end #/Console
end #/Admin
end #/SiteHtml
