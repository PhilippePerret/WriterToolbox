# encoding: UTF-8
=begin

@usage :  CMD + i

Ce module permet de comptabiliser le nombre de pages réelles
dans la collection Narration de façon indépendante du programme
pour être sûr que les calculs sont justes (en attendant d'être
certain que le calcul dans l'état des lieux est juste).

L'idée est de lancer ce script, de lancer la commande
`inventory narration` et de comparer tous les résultats.

=end
require 'singleton'
require 'sqlite3'

class Fixnum
  def rjust params ; self.to_s.rjust params end
  # def ljust params ; self.to_s.ljust params end
end
class Float
  def rjust params ; self.to_i.to_s.rjust params end
  # def ljust params ; self.to_s.ljust params end
end

class Report
  include Singleton
  # Ouvre le fichier dans Firefox
  def open
    close_file
    `open -a Firefox #{path}`
  end
  def open_file
    file.write <<-HTML
<!DOCTYPE html><html><head><meta http-equiv="Content-type" content="text/html; charset=utf-8"><title>RAPPORT PAGES NARRATION #{Time.now}</title><style>body{font-size:15pt}</style></head><body>
<pre>
| #{'TITRE'.ljust(30)} |         Files         |      Pages      |
|-#{'-'.ljust(30,'-')}-|-----------------------|-----------------|
| #{'     '.ljust(30)} | Tot |Paper|Onlin| NoD | Min | Moy | Max |
    HTML
    file.write separator
    @is_opened = true
  end
  def close_file
    write "</pre></body></html>"
    file.close
  end
  def explication
    <<-HTML

* La colonne "Files / Paper" indique le nombre de fichiers qui seront utilisés
  dans la version Papier. Seuls ces fichiers sont comptabilisés au niveau du
  nombre de pages.
* La colonne "Files / Onlin" indique le nombre de fichiers qui ne seront pas
  imprimés dans la collection papier. Ils ne sont pas comptabilisés dans le
  nombre de pages.
* La colonne "Files / NoD" contient le nombre de fichiers physiques n'ayant pas
  de fichiers de données dans la base.

    HTML
  end
  def separator
    @separator ||= "|#{'-'*74}|\n"
  end
  def write str
    open_file unless @is_opened
    file.write str
  end
  def error str
    @errors ||= Array::new
    @errors << str
  end
  # Le fichier dans lequel on va écrire le code
  def file
    @file ||= begin
      File.unlink(path) if File.exist?(path)
      File.open(path,'wb')
    end
  end
  def path; @path ||= './tmp/narration_compte_pages.html' end
end

# ---------------------------------------------------------------------
#
class Livre
  attr_reader :id
  attr_reader :name
  attr_reader :data
  attr_reader :folder_name
  def initialize livre_id, data
    @id           = livre_id
    @data         = data
    @name         = data[:hname]
    @folder_name  = data[:folder]
  end
  def nombre_files
    @nombre_files ||= files_erb.count
  end
  # Toutes les pages (ERB) du dossier
  def files_erb
    pages_erb = Dir["#{folder}/**/*.erb"]
  end
  def folder
    @folder_pages ||= File.join(FOLDER_PAGES, folder_name)
  end
end

# --- Paths --------------------------------------------------------------
FOLDER_LIB_CNARRATION = "./objet/cnarration/lib"
FOLDER_PAGES = './data/unan/pages_semidyn/cnarration'

# On doit requérir les constants de Narration
require "#{FOLDER_LIB_CNARRATION}/required/constants"

# --- DATA DES FICHIERS ----------------------------------------------------
@files = Hash::new
# Table de correspondance entre le handler et l'identifiant
# du fichier
@handler_to_id = Hash::new
bdd = SQLite3::Database::new('./database/data/cnarration.db')
bdd.execute("SELECT * FROM pages").each do |dfile|
  id, handler, livre_id, titre, rine, options, cdate, udate = dfile
  not_papier = options[2] == "1"
  is_page           = options[0] == "1"
  is_sous_chapitre  = options[0] == "2"
  is_chapitre       = options[0] == "3"
  @files.merge!(
    id => {
    id: id, livre_id:livre_id, handler:handler, titre:titre, options:options,
    created_at:cdate, updated_at:udate,
    papier:!not_papier, is_page:is_page, is_sous_chapitre:is_sous_chapitre,
    is_chapitre:is_chapitre}
  )
  @handler_to_id.merge!(handler => id) if is_page
end

# --- RAPPORT --------------------------------------------------------------

r = Report.instance

# Hash pour mettre les résultats
@result = Hash::new

nombre_files_total = 0
total_files_papier = 0
total_files_online = 0
total_files_not_traited = 0

total_pages_min = 0
total_pages_moy = 0
total_pages_max = 0

@rapport_string = Array::new

Cnarration::LIVRES.each do |lid, dbook|
  livre = Livre::new(lid, dbook)
  @rapport_string << "\n\n*** LIVRE #{dbook[:hname]} ***"

  # Composition de la ligne
  titre =  livre.name.ljust(30)
  lnf   = "#{livre.nombre_files.rjust(3)} "


  # Boucle sur toutes les pages du livre
  # ------------------------------------
  nombre_files_papier = 0
  nombre_files_online = 0
  nombre_files_non_traited = 0
  nombre_pages_min = 0
  nombre_pages_moy = 0
  nombre_pages_max = 0

  livre.files_erb.each do |pfile|
    # @rapport_string << "  - #{pfile}"
    fhandler = pfile.sub(/^#{FOLDER_PAGES}\/#{livre.folder_name}\//,'')[0..-5]
    fid = @handler_to_id[fhandler]
    hfile = @files[fid]
    @rapport_string << "  - #{livre.folder_name}/#{hfile[:handler]}"

    # Fichier physique qui n'a pas de donnée dans la base de donnée
    if hfile.nil?
      nombre_files_non_traited += 1
      r.error "Le fichier physique `#{pfile}` n'a pas d'enregistrement dans la base de données."
      next
    end

    if hfile[:papier]
      # Version papier => on compte le nombre de pages
      nombre_files_papier += 1
      code_file = File.open(pfile,'r'){ |f| f.read }.force_encoding('utf-8')
      # On remplace les balise ERB par un code fictif, entendu que
      # ces balises renverront toujours un code
      code_file.gsub!(/<%=(.*?)%>/,'CODE-ERB-FICTIF')
      # Toutes les autres balises, on les supprime
      code_file.gsub!(/<(.*?)>/,'')
      nombre_signes = code_file.length.to_f
      min = nombre_signes / 2000
      moy = nombre_signes / 1750
      max = nombre_signes / 1500
      nombre_pages_min += min
      nombre_pages_moy += moy
      nombre_pages_max += max
      @rapport_string << "    = min:#{min.round(2)} moy:#{moy.round(2)} max:#{max.round(2)}"
    else
      # Version seulement online
      nombre_files_online += 1
    end

  end
  @rapport_string << "  NOMBRE FICHIERS #{nombre_files_papier + nombre_files_online}"


  total_files_papier += nombre_files_papier
  total_files_online += nombre_files_online
  total_files_not_traited += nombre_files_non_traited
  total_pages_min += nombre_pages_min
  total_pages_moy += nombre_pages_moy
  total_pages_max += nombre_pages_max

  nfp = nombre_files_papier.rjust(4)
  nfo = nombre_files_online.rjust(4)
  nfn = nombre_files_non_traited.rjust(4)
  npi = nombre_pages_min.rjust(4)
  npy = nombre_pages_moy.rjust(4)
  npx = nombre_pages_max.rjust(4)

  # Constitution de la ligne de rapport pour le livre courant
  r.write "| #{titre} |#{lnf} |#{nfp} |#{nfo} |#{nfn} |#{npi} |#{npy} |#{npx} |\n"

  nombre_files_total += livre.nombre_files

end

# La ligne des totaux
nft = nombre_files_total.rjust(4)
tfp = total_files_papier.rjust(4)
tfo = total_files_online.rjust(4)
tfn = total_files_not_traited.rjust(4)
tpi = total_pages_min.rjust(4)
tpy = total_pages_moy.rjust(4)
tpx = total_pages_max.rjust(4)
r.write r.separator
r.write "| #{'TOTAUX'.rjust(30)} |#{nft} |#{tfp} |#{tfo} |#{tfn} |#{tpi} |#{tpy} |#{tpx} |\n"
r.write r.separator
r.write r.explication

r.write "<h3>Rapport d'évaluation</h3>"
r.write @rapport_string.join("\n") + "\n"
r.open
