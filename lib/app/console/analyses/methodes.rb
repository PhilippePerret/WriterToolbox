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

  class Analyses
    include Singleton

    def infos_films
      @infos_films ||= table_films.select(where:"options IS NOT NULL AND options LIKE `1%`")
    end

    def table_films
      @table_films ||= site.db.create_table_if_needed('analyse', 'films')
    end
    def table_filmodico
      @table_filmodico ||= site.db.create_table_if_needed('filmodico', 'films')
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

end #/Console
end #/Admin
end #/SiteHtml
