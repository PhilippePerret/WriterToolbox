# encoding: UTF-8
class Ranking

  # = main =
  #
  # Construction du rapport
  #
  def report
    # On demande l'analyse des résultats
    analyze_resultats

    perdomain = resultats[:per_domain]
    perdomain = perdomain.sort_by{|ud, dd| dd[:count]}.reverse
    perdomain.each do |ud, dd|
      puts "- Domain: #{ud} / #{dd[:count]} fois"
    end
  end

end #/Ranking
