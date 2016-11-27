# encoding: UTF-8
class AnalyseBuild

  # Données javascript a donner au programme d'extraction
  def data_javascript
    <<-JS
<script type="text/javascript">
const FILM_DUREE_SECONDES = #{film.duree};
</script>
    JS
  end

end #/AnalyseBuild
