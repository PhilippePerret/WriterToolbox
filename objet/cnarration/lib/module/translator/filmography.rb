# encoding: UTF-8
class Cnarration
class Filmography
class << self

  # Méthode appelée à l'initiation de l'export de la
  # collection pour savoir s'il faut reconstruire la filmographie.
  # Elle est à reconstruire dans seulement deux cas :
  #   1. Lorsque le fichier .bib n'existe pas
  #   2. Lorsque ce fichier est plus vieux dans la base
  #      filmodico.db
  #
  def build_if_needed
    return if bib_file.exist? && bib_file.mtime > base_filmodico.mtime
    # Sinon il faut reconstruire la bibliographie
    debug "LE FICHIER #{bib_file} (filmographie) doit être actualisé."
    build
  end

  # = main =
  #
  # Méthode qui construit la filmographie pour latex
  # en prenant tous les films du filmodico et en en faisant un fichier
  # .bib pour LaTex
  #
  # @usage    Cnarration::Filmography::build
  def build
    bib_file.remove if bib_file.exist?
    films.each do |fid, fdata|
      ref_bib_file.puts code_film( fdata )
    end
  rescue Exception => e
    debug e
    error e.message
  ensure
    ref_bib_file.close
  end

  # Code pour un film
  # +hfilm+ {Hash} des données du film telles que lues dans la
  # base de données
  def code_film hfilm
    <<-CODE
@Book{#{hfilm[:film_id]},
  title     = {#{hfilm[:titre]}},
  titlefr   = {#{hfilm[:titre_fr] || ""}},
  year      = {#{hfilm[:annee]}},
  country   = {#{hfilm[:pays].join(', ')}},
  author    = {#{hfilm[:auteurs]}},
  director  = {#{hpeople hfilm[:realisateur]}},
  publisher = {#{hpeople hfilm[:producteurs]}},
  id        = {#{hfilm[:film_id]}}
}


    CODE
  end
  def hpeople arr
    arr.collect do |hperson|
      c = "#{hperson[:nom]}, #{hperson[:prenom]}"
      c += " (hperson[:fonction].downcase)" unless hperson[:fonction].nil?
      c
    end.pretty_join.sub(/ et /, ' and ')
  end

  # {Hash} de tous les films du filmodico avec en clé l'identifiant
  # numérique du film et en valeur le hash de toutes ses données.
  def films
    @films ||= table_films.select(order:"titre ASC")
  end

  def table_films
    @table_films ||= BdD::new(base_filmodico.to_s).table('films')
  end

  # Référence au fichier ouvert en écriture (append)
  def ref_bib_file
    @ref_bib_file ||= begin
      File.open(bib_file.to_s, 'a')
    end
  end

  # {SuperFile} fichier filmodico.db contenant tous les
  # films dans la table films.
  def base_filmodico
    @base_filmodico ||= site.folder_db + "filmodico.db"
  end

  # {SuperFile} Fichier contenant la filmographie
  # au format LaTex
  def bib_file
    @bib_file ||= begin
      Cnarration::Translator::folder + "assets/filmography.bib"
    end
  end

end #/<< self Filmography
end #/Filmographie
end #/Cnarration
