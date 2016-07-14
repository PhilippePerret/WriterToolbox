# encoding: UTF-8
# =begin
# Pour transformer les pages Narration récupérées (HTML ou STR) en fichier MD
#
# Note : Peut même fonctionner avec des pages Latex, mais à surveiller.
#
# =end


puts <<-TXT


TRANSFORMATION DE FICHIER NARRATION ANCIENNE VERSION

Il est plus pratique de déplacer les fichiers dans un dossier du
site de la boite à outils.

TXT

path = ARGV[0]
path != nil && path != '' || raise("\n\nIl faut indiquer le path du fichier !")
path = path.gsub(/ /, '\\ ')
File.exist?(path) || raise("\n\nLe fichier '#{path}' est introuvable. Merci de vérifier le path.")
puts "Traitement du fichier #{path}"

class MFile

    attr_reader :path

    def initialize path
        @path = path
    end
    def is_str?
        @is_str ||= extension == "str"
    end

    def is_tex?
        @is_tex ||= extension == 'tex'
    end
    def is_html?
      @is_html ||= extension == 'htm' || extension == 'html'
    end
    def extension
        @extension ||= File.extname(name)[1..-1]
    end
    def affixe
        @affixe ||= File.basename(path, File.extname(path))
    end
    def name
        @name ||= File.basename(path)
    end
    def read
        File.open(path,'rb'){|f| f.read.force_encoding('utf-8')}
    end

    def transform
        c = read
        c = c.gsub(/<p(.*?)>/, "\n\n").gsub(/<\/p>/, "\n\n")

        # Quelques caractères spéciaux
        {
            '&nbsp;'  => ' ',
            '~'       => ' '
        }.each do |bad, bon|
            c = c.gsub(/#{Regexp::escape bad}/, bon)
        end

       # Version Tex
        if is_tex?
            c = c.gsub(/\\personnage\{(.*?)\}/){
                "personnage:|#{$1}|"
            }
            c = c.gsub(/\\emph\{(.*?)\}/){
                "*#{$1}*"
            }
            c = c.gsub(/\\exergue\{(.*)\}/){
                "> #{$1}"
            }
            c = c.gsub(/\\tterm{(.*?)\}/){
                "tt:|#{$1}|"
            }
        end
        # Version STR
        if is_str?
            # Les commentaires fonctionnent comme en ruby, avec un dièse
            # devant
            c = c.gsub(/^#(.*?)$/){
                com = $1.strip.freeze
                if com.start_with?("TODO")
                    "<adminonly>\n  #{com}\n</adminonly>"
                else
                    "<!--\n#{com}\n-->"
                end
            }

            {
                "\nexergue:"    => "\n> ",
                "\nenv:list"    => '',
                "\nend:list"    => '',
                /\n(  |\t)\*/   => "\n* ",
                'tterm:'        => 'tt:'
            }.each do |bad, bon|
                c = c.gsub(/#{bad}/, bon)
            end
        end


        # Les mots du scénodico
        c = c.gsub(/<a onclick=\"Scenodico.show\(([0-9]+)\)\"(?:.*?)\">(.*?)<\/a>/){
            mot_id  = $1
            mot     = $2
            "MOT[#{mot_id}|#{mot}]"
        }

        # Les films du filmodico
        # <a onclick="$.proxy(Filmodico,'show','12AngryMen1957')()" class="film" href="javascript:void(0)">12 Angry Men (Douze hommes en colère)</a>
        c = c.gsub(/<a(?:[^>]*)\$\.proxy\(Filmodico, ?'show', ?'([a-zA-Z0-9]+)'([^>]*)>(.*?)<\/a>/){
            film_id = $1.freeze
            "FILM[#{film_id}]"
        }
        # Cf. aussi plus bas d'autres transformations de film:

        # Les titres
        c = c.gsub(/<(h([0-6]))>(.*?)<\/\1>/){
            traite_titre_page $3.freeze, $2.to_i
        }
        c = c.gsub(/^(=+)(.*)\1$/){
            traite_titre_page($2.strip.freeze, $1.freeze.length)
        }
        
        c = c.gsub(/\\(chapter|section|subsection)\{(.*?)(\|(.*?))?\}/){
            div = $1.freeze
            titre = $2.freeze
            level = case div
                    when "chapter"    then 3
                    when "section"    then 4
                    when "subsection" then 5
                    end
            "#{'#' * level} #{titre}"
        }

        # Les listes
        c = c.gsub(/<ul(?:.*?)>(.*?)<\/ul>/m){
            inner = $1.to_s
            inner.gsub!(/<li(?:.*?)>(.*?)<\/li>/){
                "* #{$1}\n"
            }
            inner = inner.gsub(/\n(\n*)/, "\n")
            "\n\n#{inner}\n\n"
        }

        # Les termes techniques et autres balises span
        c = c.gsub(/<span class='(tt|auteur|personnage|acteur)'>(.*?)<\/span>/, '\1:|\2|')
        c = c.gsub(/<em>(.*?)<\/em>/, '*\1*')
        c = c.gsub(/em:\|(.+?)\|/, '*\1*')
        c = c.gsub(/em:(.+?)\b/, '*\1*')

        # Les versions Latex
        c = c.gsub(/\\enquote\{(.*?)\}/, '*\1*')

        # Livres à l'ancienne
        c = c.gsub(/\[\[livre:(.*?)\|(.*?)\]\]/, '<livre>\2</livre>')

        # Films à l'ancienne
        c = c.gsub(/film:(.*?)[^a-zA-Z0-9]/,'FILM[\1]')

        # Insécables
        c = c.gsub(/ [\!\?\:\;]/, ' \1')
        c = c.gsub(/ — (.*?) —/, '— \1 —')

        c.gsub!(/\n(\n+)/, "\n\n")
        return c
    end

    def traite_titre_page titreancre, level
        titre, ancre = titreancre.split("|")
        t = ""
        t += "<a name='#{ancre}'></a>\n\n" unless ancre.nil?
        t += "#{'#' * level} #{titre}"
    end

end
sfile = MFile.new(path)
folder_dest = "/Users/philippeperret/Sites/WriterToolbox/data/unan/pages_cours/cnarration"
sfile_dest = folder_dest + "#{sfile.affixe}.md"
File.unlink(sfile_dest) if File.exist?(sfile_dest)
File.open(sfile_dest, 'wb'){|f| f.write sfile.transform}
puts "LE FICHIER A ÉTÉ PLACÉ DANS #{sfile_dest}"
# On ouvre le fichier dans TextMate
`mate "#{sfile_dest}"`
