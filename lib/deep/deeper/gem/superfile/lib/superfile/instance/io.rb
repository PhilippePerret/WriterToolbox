# encoding: UTF-8
require 'erb'

class SuperFile
  
  
  # Ecrit le texte +str+ dans le fichier
  def write str
    unless exist? && directory?
      begin
        make_dir dirname unless File.exist? dirname
        File.open(path, 'wb'){ |f| f.write str }
        return true
      rescue Exception => e
        return add_error e.message
      end
    else
      raise "Can't write a folder…"
    end
  end
  
  # Ajoute du texte au fichier (ou le crée)
  def add str
    if !exist? || file?
      make_dir dirname unless File.exist? dirname
      File.open(path, 'a'){ |f| f.write str }
      return true
    else
      raise "Can't add to a folder…"
    end
  end
  alias :append :add
  
  
  # Lit le fichier ou retourne la liste des NOMS de files du 
  # dossier
  def read
    raise ERRORS[:inexistant] % {path: path} unless exist?
    if file?
      # Pour un fichier
      File.read(path).force_encoding('utf-8')
    else
      # Pour un dossier
      Dir.glob("#{path}/*").collect {|m| File.basename(m) }
    end
  end
  
  # Lit le fichier est l'écrit dans la sortie standard
  alias :top_puts :puts
  def puts
    if false == exist?
      raise ERRORS[:inexistant] % {path: path}
    elsif folder?
      raise "Can't (out)put a folder…"
    else
      top_puts read
    end
  end
  
  # @return le code HTML du fichier en fonction de son format
  # +bind+ Si la méthode est appelée directement (pour obtenir le code
  # du fichier), on peut fournir en premier argument l'objet à binder
  # à la vue ou son binding directement
  attr_writer :code_html # pour les tests
  def code_html bind = nil
    set_binding bind unless bind.nil?
    @code_html ||= begin
      c = ""
      begin
        c << link_for_opening_in_textmate if self.respond_to?( :link_for_opening_in_textmate )
      rescue Exception => e
        raise "#Erreur avec la méthode `SuperFile#link_for_opening_in_textmate' propre au programme : #{e.message}"
      end
      c << case extension
      when 'erb'
        self.deserb @bind
      when 'html', 'htm', 'txt'  
        read
      when 'md', 'markdown'
        # Pour un fichier Markdown, on essaie toujours de lire son fichier
        # HTML et on l'actualise ou on le construit pour la première fois
        # si nécessaire.
        update unless uptodate?
        if html_path.exist?
          html_path.read
        else
          "Fichier #{html_path.path} inexistant."
        end
      else # Format de fichier inconnu, on le lit tel quel
        read
      end
    end
  end
  
  # {String}
  # Déserbe le fichier (si c'est un fichier ERB) et retourne son contenu
  # +bindee+    L'objet bindé à la vue, éventuellement
  def deserb bindee = nil
    raise "Ce fichier n'est pas un fichier ERB." unless extension == 'erb'
    bindee ||= @bind
    unless bindee.nil?
      if bindee.class != Binding && false == bindee.respond_to?(:bind)
        raise "Un objet à binder doit répondre à la méthode `bind' (définie par : `def bind; binding() end')"
      end
      bindee = bindee.bind unless bindee.class == Binding
    end
    ERB::new( read ).result( bindee )
  end
  
end