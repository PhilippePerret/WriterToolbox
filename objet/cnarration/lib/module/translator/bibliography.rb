# encoding: UTF-8
class Cnarration
class Bibliography
class << self

  # Méthode appelée à l'initiation de l'export de la
  # collection pour savoir s'il faut reconstruire la filmographie.
  # Elle est à reconstruire dans seulement deux cas :
  #   1. Lorsque le fichier .bib n'existe pas
  #   2. Lorsque ce fichier est plus vieux dans la base
  #      filmodico.db
  #
  # @usage :      Cnarration::Bibliography::build_if_needed
  def build_if_needed
    return if Cnarration::force_update_biblios.nil? && bib_file.exist? && bib_file.mtime > constants_biblio_file.mtime
    # Sinon il faut reconstruire la bibliographie
    debug "LE FICHIER #{bib_file} (bibliographie) doit être actualisé."
    build
  end

  # = main =
  #
  # Méthode qui construit la bibliographie pour latex
  # en prenant tous les livres définis dans le fichier
  # ./objet/cnarration/lib/required/bibliographie.rb +
  # la définition des livres
  # et en en faisant un fichier .bib pour LaTex
  #
  # @usage    Cnarration::Bibliography::build
  def build
    bib_file.remove if bib_file.exist?
    livres.each do |lid, ldata|
      ref_bib_file.puts code_livre( ldata )
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
  #
  # volumes
  # series + number
  def code_livre hlivre
    <<-CODE
@book{#{hlivre[:id]},
  title     = {#{hlivre[:titre].to_latex}},
  author    = {#{hlivre[:auteur]}},
  year      = {#{hlivre[:annee]}},
  publisher = {#{hlivre[:editeur]}},
  isbn      = {#{hlivre[:isbn]}},
  series    = {#{hlivre[:series]}},
  id        = {#{hlivre[:id]}}
}


    CODE
  end
  def hpeople arr
    arr.collect do |hperson|
      c = "#{hperson[:nom]}, #{hperson[:prenom]}"
      c
    end.join(' and ') # oui, entre chaque personne
  end

  # {Hash} de tous les livres, ceux de la collection Narration
  # et ceux définis dans le fichier
  # ./
  def livres
    @livres ||= begin
      hlivres = Hash::new
      Cnarration::LIVRES.each do |bid, bdata|
        nid = "NarrationID#{bid}"
        hlivres.merge!( nid => bdata.merge(
            titre:    bdata[:hname],
            id:       nid,
            auteur:   "Perret, Philippe",
            editeur:  "Encres de Siagne",
            series:   "Collection Narration",
            annee:    Time.now.year
        ) )
      end
      hlivres.merge(Cnarration::BIBLIOGRAPHIE)
    end
  end


  # Référence au fichier ouvert en écriture (append)
  def ref_bib_file
    @ref_bib_file ||= begin
      File.open(bib_file.to_s, 'a')
    end
  end

  # {SuperFile} fichier filmodico.db contenant tous les
  # films dans la table films.
  def constants_biblio_file
    @base_filmodico ||= Cnarration::folder+'lib/required/bibliographie.rb'
  end

  # {SuperFile} Fichier contenant la filmographie
  # au format LaTex
  def bib_file
    @bib_file ||= begin
      Cnarration::Translator::folder + "assets/commons/bibliography.bib"
    end
  end

end #/<< self Bibliography
end #/Bibliography
end #/Cnarration
