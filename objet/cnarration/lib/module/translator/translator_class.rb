# encoding: UTF-8
class Cnarration
class Translator

  class << self

    # Méthode qui charge les librairies de corrections
    # en fonction du format de sortie du fichier,
    # latex ou html
    def load_librairies_if_needed output_format
      return if @libraries_already_added
      pfolder = folder + "translator_patch_format/#{output_format}"
      Dir["#{pfolder}/**/*.rb"].each { |p| load p }
      @libraries_already_added = true
    end

    # {SuperFile} Dossier principal du module
    def folder
      @folder ||= Cnarration::folder+"lib/module/translator"
    end

  end #/<< self
end #/Translator
end #/Cnarration
