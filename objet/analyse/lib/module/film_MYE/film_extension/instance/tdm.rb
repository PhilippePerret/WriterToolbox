# encoding: UTF-8
=begin
Méthodes d'helper
=end

class FilmAnalyse
class Film

  def tdm
    @tdm ||= begin
      if tdm_file.exist?
        tdm_file.deyamelize
      else
        # Si aucun fichier tdm existe, on relève la liste
        # des fichiers dans les dossiers de l'analyse en
        # mettant en titre le nom du fichier
        Dir["#{folder_in_films_mye}/**/*.*"].collect do |fpath|
          {
            titre:  affixe2titre(File.basename(fpath, File.extname(fpath))),
            path:   fpath.gsub(/#{folder_in_films_mye}\//,'')
          }
        end
      end
    end
  end

  # Reçoit l'affixe d'un fichier d'analyse et retourne le
  # titre correspondant. Par exemple retourne "Procédés" quand l'affixe
  # est "procede".
  # Noter que cette méthode n'est utilisée que lorsque le fichier tdm.yaml
  # n'est pas défini et qu'il faut tirer le titre du nom du fichier
  def affixe2titre affixe
    case affixe
    when 'procedes'     then "Procédés"
    when 'dynamique'    then "Dynamique narrative (objectifs-obstacles-conflit)"
    when 'qrds'         then "Questions & réponses dramatiques"
    when 'chrono'       then "Chronométrage complet du film"
    when 'lecon_tiree'  then "La Leçon tirée du film"
    when 'themes'       then "Thèmes"
    else
      @alerte_tdm_pas_etablie_necessaire = true
      affixe.gsub(/_/, ' ').capitalize
    end
  end
end # /Film
end # /FilmAnalyse
