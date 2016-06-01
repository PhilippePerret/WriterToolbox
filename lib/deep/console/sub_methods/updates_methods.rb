# encoding: UTF-8
class SiteHtml
class Admin
class Console

  def exec_updates params
    case params
    when /^liste?$/
      affiche_table_of_database 'site_cold.updates'
    when /^show$/
      redirect_to 'site/updates'
    when /^show online$/
      flash "Pas encore implémenté"
    else
      site.new_update(Data::by_semicolon_in( params ))
    end
    return ""
  end

end #/Console
end #/Admin
end #/SiteHtml
