# encoding: UTF-8
class TestedPage

  def url
    @url ||= begin
      case route
      when  /^https?\:\/\// then route
      else File.join(self.class.base_url, route)
      end
    end
  end

  # La profondeur du lien, de page en page.
  # La première page testée à une profondeur de 0, les
  # pages de ses liens ont une profondeur de 1, les liens
  # de ces pages ont une profondeur de 2, etc.
  #
  # Les pages pouvant être appelées par différentes
  # pages, elles ont différentes profondeurs, d'où
  # une liste pour garder leur profondeur.
  def depths ; @depths ||= Array.new end

  # La première profondeur. Elle sert notamment quand on ne
  # doit aller que jusqu'à une certaine profondeur.
  def depth; @depth ||= depths.first end

  # Le nombre d'appels de cette page
  def call_count ; @call_count ||= 0 end
  def call_count= value; @call_count = value end

  # Liste des textes qui ont appelé cette route
  def call_texts  ; @call_texts ||= Array.new end
  def call_texts= val; @call_texts = val end

  # Liste des IDs des instance TestedPage qui ont
  # appelé cette route
  def call_froms  ; @call_froms ||= Array.new end
  def call_froms= val; @call_froms = val end

  # {TestedPage} Page ayant appelé cette page
  #
  # Pour le moment, on s'en sert par exemple pour obtenir le code
  # d'une page ayant défini une route-ancre.
  def referer
    TestedPage[call_froms.last]
  end

  # Status retourné
  def html_status
    @html_status ||= begin
      c = `#{curl_command_header_only}`
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
