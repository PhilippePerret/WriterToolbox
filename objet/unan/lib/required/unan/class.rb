# encoding: UTF-8
=begin

Class Unan
----------
Gestion du programme UN AN
La classe gère le programme dans sa globalité, comme programme de cours
et de création.
Pour un programme en particulier, voir la classe Unan::Program

=end

class Unan

  extend MethodesMainObjets

  class << self

    # Requérir les données
    def require_data
      self.folder_data.require
    end

    def tarif_humain(with_tarif_mois = false)
      if with_tarif_mois
        tarif_humain(false) + " (#{tarif_humain_par_mois})"
      else
        @tarif_humain ||= tarif.as_tarif
      end
    end
    alias :montant_humain :tarif_humain

    def tarif_humain_par_mois(suffix = "&nbsp;par&nbsp;mois")
      parmois = (tarif / 12).round(1).as_tarif
      "~ #{parmois}#{suffix}"
    end

    def description
      @description ||= ""
    end

    def tarif
      @tarif ||= 19.80
    end

    # Permet d'écrire le titre "Un An Un Script" de façon
    # correcte, avec un sous-titre (h2) s'il est défini
    def titre_h1 sous_titre = nil
      @titre_h1 ||= begin
        page_title = Unan::PROGNAME_MINI_MAJ
        page_title += "#{site.title_separator}#{sous_titre}" if sous_titre
        page.title = page_title
        titre = Unan::PROGNAME_MINI_MAJ
        titre.in_a(href:"unan/home").in_h1
      end
      if sous_titre
        @titre_h1 + sous_titre.in_h2
      else
        @titre_h1
      end
    end

    def bind; binding() end
  end # << self
end
