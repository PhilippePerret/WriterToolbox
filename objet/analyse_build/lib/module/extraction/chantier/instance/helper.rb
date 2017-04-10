# encoding: UTF-8
#
# COPIÉES DANS COLLECTE
#
class AnalyseBuild

  FEUILLES_DE_STYLES = [
    # l'id doit être une clé de
    {id: 'evenemencier',  affixe: 'evenemencier',   title: 'Évènemencier'},
    {id: 'chemindefer',   affixe: 'chemin_de_fer',  title: 'Chemin_de_fer'},
    {id: 'sequencier',    affixe: 'sequencier',     title: 'Séquencier'}
  ]

  # Données javascript a donner au programme d'extraction
  def data_javascript
    liste_feuille_de_styles = FEUILLES_DE_STYLES.collect{|dcss| "'#{dcss[:id]}'"}.join(', ')
    <<-JS
<script type="text/javascript">
const FILM_DUREE_SECONDES = #{film.duree};
const FEUILLES_DE_STYLES  = [#{liste_feuille_de_styles}];
</script>
    JS
  end

  def feuilles_de_styles_alternatives
    FEUILLES_DE_STYLES.collect do |dcss|
      titre   = dcss[:title]
      cssname = dcss[:affixe]
      "<link id=\"analyse_thing_#{dcss[:id]}\" title=\"#{titre}\" href=\"./data/analyse/css/extract/#{cssname}.css\" rel=\"alternate stylesheet\" />"
    end.join("\n")
  end

end #/AnalyseBuild
