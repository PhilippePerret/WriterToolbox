# encoding: UTF-8
class SiteHtml
class Admin
class Console

  # = main =
  #
  # Méthode principale appelée pour faire l'état des lieux
  # des analyses de film
  #
  def affiche_rappel_fonctionnement
    c = Array::new
    c << Analyses.instance.rappels_fonctionnement
    c = c.join('')
    sub_log "=> Rappel fonctionnement des analyses</div>#{c}<div>"
    return ""
  end

  def build_manuel_analyste
    site.require_objet 'analyse'
    (FilmAnalyse::folder+"manuel/build.rb").require
    return ""
  end

  def affiche_aide_balise_analyses
    "Ajouter à la commande `(lien|balise) analyse` le titre ou seulement une portion du titre (original ou français) ou de l'identifiant."
    return ""
  end

  class Analyses
    include Singleton


    # Produit une liste des balises pour conduire
    # aux analyses voulues
    def liens_balises_vers portion_titre
      site.require_objet 'analyse'
      console.require 'filmodico'
      hfilms = console.get_all_films_of_ref(portion_titre)

      liste_balises = Array::new
      if hfilms.count == 0
        return [nil, "AUCUN FILM TROUVÉ AVEC LES RÉFÉRENCES DONNÉES"]
      else
        hfilms.each do |hfilm|
          ifilm = FilmAnalyse::Film::get(hfilm[:id])
          if ifilm.analyzed?
            relative_url = "analyse/#{ifilm.id}/show"
            absolute_url = "#{site.distant_url}/#{relative_url}"
            lien = hfilm[:titre].in_a(href:"analyse/#{hfilm[:id]}/show")
            liste_balises << {value:"[#{ifilm.titre}](#{relative_url})", after:"Markdown #{lien}"}
            liste_balises << {value:relative_url, after: "Brut"}
            liste_balises << {value:"<a href=\"#{absolute_url}\">#{ifilm.titre}</a>", after:"Lien mail"}
          else
            liste_balises << {value:"", after:"#{hfilm[:titre]} n'est pas analysé."}
          end
        end
        return [liste_balises, ""]
      end
    end

    # Redirige vers l'analyse correspondant à la référence
    # +portion_titre
    def redirect_to_analyse_of portion_titre
      site.require_objet 'analyse'
      console.require 'filmodico'
      hfilms = console.get_all_films_of_ref(portion_titre)
      if hfilms.count == 1
        hfilm = hfilms.first
        ifilm = FilmAnalyse::Film::get(hfilm[:id])
        if ifilm.analyzed?
          redirect_to "analyse/#{hfilm[:id]}/show"
        else
          return "Ce film n'est pas analysé"
        end
      elsif hfilms.empty?
        return "AUCUN FILM TROUVÉ AVEC LES RÉFÉRENCES DONNÉES"
      else
        res = hfilms.collect do |hfilm|
          ifilm = FilmAnalyse::Film::get(hfilm[:id])
          next unless ifilm.analyzed?
          hfilm[:titre].in_a(href:"analyse/#{hfilm[:id]}/show").in_div
        end.join('').in_div
        console.sub_log res
      end
      return ""
    end


    def infos_films
      @infos_films ||= table_films.select(where:"options IS NOT NULL AND options LIKE `1%`")
    end

    def table_films
      @table_films ||= site.dbm_table(:biblio, 'films_analyses')
    end
    def table_filmodico
      @table_filmodico ||= site.dbm_table(:biblio,'filmodico')
    end

    def rappels_fonctionnement
      <<-HTML

<div class='right small btns'><a onclick="$('div#rappels_du_fonctionnement').toggle()">Rappels du fonctionnement</a></div>
<div id="rappels_du_fonctionnement" style="display:none;">
  <h4>Rappels du fonctionnement général</h4>
  <p>
    La table des films propres aux analyses contient tous les films du Filmodico, mais seuls les enregistrements définissant la valeur `options`  avec un premier bit à 1 sont vraiment des films analysés.
  </p>
  <p>
    Cette table ne contient que les informations minimales sur le film, mais en créant une instance `FilmAnalyse::Film` on peut obtenir toutes les autres informations. On peut également faire appel à une instance `Filmodico` pour obtenir toutes les méthodes de formatage.
  </p>
  <p>
    Il existe <strong>deux types d'analyses</strong> :<ul>
      <li>Les analyses dites “TM” pour “TextMate” qui ont été réalisées avec le bundle TextMate et permettent des analyses statistiques poussées.</li>
      <li>Les analyses dites “MYE” pour “Markdown, Yaml et Evc” qui contiennent des fichiers dans ces trois types. Ce sont les anciennes analyses, mais on peut imaginer d'en produire encore, car elles sont plus pertinentes au niveau littéraire. On pourra imaginer des analyses des deux types.</li>
    </ul>
  </p>
  <hr>
</div>

      HTML
    end
  end

  # Prend un fichier de collect TM et en tire une timeline des
  # scènes à introduire dans une analyse.
  def build_timeline_from_film_tm fpath
    site.require_objet 'analyse'
    FilmAnalyse.require_module 'timeline_scenes'
    FilmAnalyse.from_tm_to_timeline fpath
    sub_log 'Timeline des scènes construite'
    return ''
  end

end #/Console
end #/Admin
end #/SiteHtml
