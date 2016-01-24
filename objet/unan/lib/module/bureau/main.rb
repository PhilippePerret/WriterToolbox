# encoding: UTF-8
=begin
Ces méthodes sont mises ici, dans ce dossier module, pour pouvoir
être chargées aussi par UnanAdmin (pour la simulation par exemple)
=end
site.require 'form_tools'

class Unan
class Bureau

  # Bouton submit commun
  # ---------------------
  # Pour avoir une cohérence entre les panneaux
  # @usage    bureau.submit_button
  def submit_button name = "Enregistrer", options = nil
    if options.nil?
      @submit_button ||= begin
        subbtn = form.submit_button(name)
        subbtn.sub!(/class="btn"/, 'class="btn tiny tres discret"')
      end
    else
      css = ['btn']
      css << 'tiny' unless options[:tiny] === false
      css << 'tres' unless options[:tres_discret] === false
      css << 'discret' unless options[:tres_discret] === false || options[:discret] === false
      subbtn = form.submit_button(name)
      subbtn.sub!(/class="btn"/, "class=\"#{css.join(' ')}\"")
    end
  end

end #/Bureau
end #/Unan
