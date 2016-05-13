# encoding: UTF-8
class SiteHtml
class TestSuite
class Html

  # Retourne un texte à ajouter aux messages d'erreur pour
  # préciser les messages contenus dans la page
  def messages_flash_as_human
    hmess = messages_flash
    debug "messages_flash: #{messages_flash.inspect}"
    nombre_errors   = hmess[:errors].count
    nombre_notices  = hmess[:notices].count
    mess_sup = if (nombre_errors + nombre_notices) == 0
      "la page n'affiche aucun message"
    else
      errs = hmess[:errors].collect{|e| "“#{e}”"}.join(', ')
      nots = hmess[:notices].collect{|e| "“#{e}”"}.join(', ')
      s_errors = nombre_errors > 1 ? 's' : ''
      s_notices = nombre_notices > 1 ? 's' : ''
      "la page affiche " +
      "<br>le#{s_errors} message#{s_errors} d'erreur : #{errs}" unless hmess[:errors].empty?
      "<br>le#{s_notices} message#{s_notices} : #{nots}" unless hmess[:notices].empty?
    end
  end

  # Retourne un array contenant les messages affichés dans la
  # page. Cette méthode est à appeler en cas d'erreur lorsqu'il
  # faut indiquer quels messages existent dans la page
  def messages_flash
    begin
      raise "Backtrace jusqu'à messages_flash"
    rescue Exception => e
      debug e.message
      debug e.backtrace.join("\n")
    end
    @messages_flash ||= begin
      debug "\n\n" + "-"*80
      debug "\n-> messages_flash\n"
      cont = page.css("div#flash").text.gsub(/</, '&lt;')
      debug "page.css('div#flash') : #{cont}"
      debug "\n\n" + "-"*80
      notices = page.css("div#flash div.message").collect do |edom|
        edom.text
      end
      warnings = page.css("div#flash div.error").collect do |edom|
        edom.text
      end
      { notices: notices, errors: warnings }
    end
  end

end #/Html
end #/TestSuite
end #/SiteHtml
