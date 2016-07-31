# encoding: UTF-8
class TestedUrl

  # Donnée complète enregistrée dans @hroutes, le résultat de
  # toutes les routes consultées
  def hroute
    self.class.hroutes[route]
  end

  # {TestedUrl} Page ayant appelé cette page
  #
  # Pour le moment, on s'en sert par exemple pour obtenir le code
  # d'une page ayant défini une route-ancre.
  def referer
    self.class[hroute[:testedurl]]
  end

  # Status retourné
  def html_status
    @html_status ||= begin
      c = `curl -I -s #{url}`
      c = c.gsub(/\r/,'')
      firstline   = c.split("\n").first
      hs = nil
      firstline.split(' ').each do |w|
        if w.length == 3 && w.to_i.to_s == w
          hs = w.to_i
          break
        end
      end
      hs
    end
  end

end
