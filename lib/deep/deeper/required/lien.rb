# encoding: UTF-8
class Lien
  include Singleton

  # Pour définir le format de sortie général.
  # Utilisé par l'export en LaTex de la collection Narration
  # Utilisé par la construction du manuel (Markdown) d'utilisation
  # du programme UN AN UN SCRIPT.
  #
  attr_writer :output_format
  def output_format
    @output_format || :html
  end

  # Méthode principale permettant de construire un lien
  # quelconque, pour éviter de répéter toujours le même code
  # +options+
  #   :distant    Si true, on transforme la route en URL complète
  #   :arrow_cadre  Un type de lien avec flèche et cadre
  # NOTES
  #   - Par défaut, le lien s'ouvre dans une nouvelle fenêtre.
  #     ajouter options[:target] = nil pour empêcher ce comportement
  def build route, titre, options
    options ||= {}

    type_lien = options.delete(:type)
    is_arrow_cadred = type_lien == :arrow_cadre

    route = "#{site.distant_url}/#{route}" if options.delete(:distant)
    case output_format
    when :latex
      # TODO améliorer les choses ensuite
      titre
    when :markdown
      # En markdown, on a deux solutions : si le titre est fourni,
      # on retourne un lien complet [titre](liens){... options ....}
      # Sinon, on ne retourne que l'url, sans les parenthèses
      if titre == nil
        route
      else
        options = options.collect{|k,v| "{:#{k}=\"#{v}\"}"}.join('')
        "[#{titre}](#{route})#{options}"
      end
    else
      options.merge!(href: route)
      options.key?(:target) || options.merge!(target:'_blank')
      if is_arrow_cadred
        titre = titre.in_span(class:'cadre')
        "#{ARROW}#{titre}".in_a(options)
      else
        titre.in_a(options)
      end
    end
  end


  # Retourne un lien qui est l'image du point d'interrogation
  # conduisant à un fichier d'aide d'ID +aide_id+
  #
  # Par défaut, les liens s'ouvrent toujours dans une nouvelle
  # fenêtre.
  #
  # @usage      lien.information(xxx[, options])
  # +aide_id+ {Fixnum} Identifiant du fichier d'aide, correspondant
  #           au fichier dans le dossier ./objet/aide/lib/data/texte
  def information aide_id, options = nil
    options ||= {}
    options[:class] ||= ''
    options[:class] << ' lkaide discret'
    options.key?(:target) || options[:target] = '_blank'
    options.merge!(
      href:   "aide/#{aide_id}/show",
      class:  options[:class].strip
    )
    image('pictos/picto_info_dark.png').in_a(options)
  end
  alias :aide :information

  # Similaire à `build` mais avec un nom plus parlant et l'ordre
  # est celui de Markdown. Les arguments sont également plus
  # souples :
  #   - si les deux premiers arguments sont des strings, c'est le
  #     titre et la route
  #   - si le second argument est un Hash, le premier est la route,
  #     c'est-à-dire que le titre n'est pas fourni (on ne veut par
  #     exemple qu'obtenir un href distant)
  #   - s'il n'y a qu'un seul argument, c'est la route
  #
  # Si lien.output_format est :markdown, et que le titre est défini,
  # la méthode retourne un texte de la forme "[titre](lien){...options...}"
  # Sinon, retourne simplement le "lien" sans les parenthèses.
  # Mettre en options {distant: true} pour obtenir un lien vers le site
  # distant.
  def route titre, route = nil, options = nil
    case true
    when route.nil? && options.nil? then
      route = titre.dup.freeze
      titre = nil
    when options.nil? && route.instance_of?(Hash)
      options = route.dup
      route   = titre.dup.freeze
      titre   = nil
    end
    build route, titre, options
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
    href += "?backto=#{CGI::escape(options.delete(:back_to))}" if options.key?(:back_to)
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

  def bouton_subscribe options = nil
    # type: :arrow_cadre
    options ||= {}
    options.key?(:tarif) || options.merge!(tarif: true)
    options[:titre] ||= begin
      tarif = options[:tarif] ? "<br>(pour #{site.tarif_humain}/an)".in_span(class:'tiny') : ''
      (
        "#{ARROW} S'ABONNER" + tarif
      ).in_div(class: 'cadre', style:'display:inline-block;line-height:0.6em')
    end
    subscribe(options[:titre], class: 'small vert discret').in_div(class:'right vert')
  end
  alias :bouton_abonnement :bouton_subscribe

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
      "site/open_md_file?path=#{path}" if user.admin?
      # "site/open_md_file?path=#{CGI::escape path}" if user.admin?
    else
      case editor
      when :atom
        "atm://open?url=file://#{path}"
      when :textmate
        "txmt://open/?url=file://#{path}"
      else
        "site/open_file?path=#{path}&app=#{editor}"
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
