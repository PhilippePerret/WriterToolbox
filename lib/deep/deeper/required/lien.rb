# encoding: UTF-8
class Lien
  include Singleton

  # Méthode principale permettant de construire un lien
  # quelconque, pour éviter de répéter toujours le même code
  # +options+
  #   :distant    Si true, on transforme la route en URL complète
  def build route, titre, options
    debug "-> build(route:#{route}, titre:#{titre.inspect}, options:#{options.inspect})"
    options ||= Hash::new
    route = "#{site.distant_url}/#{route}" if options.delete(:distant)
    options.merge!( href: route )
    titre.in_a(options)
  end

  # Lien pour s'inscrire sur le site
  def signup titre = "s'inscrire", options = nil
    build "user/signup", titre, options
  end
  alias :inscription :signup

  # Lien pour s'identifier
  def signin titre = "s'identifier", options = nil
    options ||= Hash::new
    href = "user/signin"
    href += "?backto=#{CGI::escape(options.delete(:back_to))}" if options.has_key?(:back_to)
    build href, titre, options
  end


  def subscribe titre = "s'abonner", options = nil
    options ||= Hash::new
    options.merge!(query_string:"user[subscribe]=on")
    build "user/paiement", titre, options
  end
  alias :suscribe :subscribe
  alias :sabonner :subscribe
  alias :abonnement :subscribe

  # Pour rejoindre la console
  def console titre = "console", options = nil
    raise_unless_admin
    build 'admin/console', titre, options
  end

  # Lien pour éditer un fichier par son path, dans l'éditeur de
  # son choix, soit Textmate, soit Atom si le fichier est d'extension
  # quelconque, sauf .md
  # Les fichiers Markdown sont ouverts par l'application "MarkdownLife"
  # si c'est réglé dans le fichier configuration
  def edit_file path, options = nil
    options ||= Hash::new
    editor  = options.delete(:editor) || site.default_editor || :atom
    titre   = options.delete(:titre) || "Ouvrir"
    line    = options.delete(:line)

    url = case File.extname(path)
    when '.md'
      "site/open_md_file?path=#{CGI::escape path}" if user.admin?
    else
      case editor
      when :atom
        "atm://open?url=file://#{path}"
      when :textmate
        "txmt://open/?url=file://#{path}"
      end
      # On compose le lien et on le renvoie
    end
    url += "&line=#{line}" unless line.nil?
    build( url, titre, options )
  end

  def forum titre = "le forum", options = nil
    build('forum/home', titre, options)
  end

end

def lien ; @lien ||= Lien.instance end
