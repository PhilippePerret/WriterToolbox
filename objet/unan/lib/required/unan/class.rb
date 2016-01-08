# encoding: UTF-8
=begin

Class Unan
----------
Gestion du programme Un An Un Script
La classe gère le programme dans sa globalité, comme programme de cours
et de création.
Pour un programme en particulier, voir la classe Unan::Program

=end

class Unan
  class << self

    # Crée un nouveau programme pour l'user courant
    # (qui vient certainement de payer son programme)
    def create_program
      (folder_modules + 'create_program.rb').require
      Program::create
    end

    def tarif_humain
      @tarif_humain ||= tarif.as_tarif
    end
    alias :montant_humain :tarif_humain

    def description
      @description ||= ""
    end

    def tarif
      @tarif ||= 29.80
    end

    def titre_h1
      @titre_h1 ||= begin
        titre = "Le Programme “<span style='letter-spacing:-1px;'>Un<span style='font-size:0.5em'> </span>An<span style='font-size:0.5em'> </span><span style='letter-spacing:-2px'>Un</span><span style='font-size:0.5em'> </span><span style='letter-spacing:-2px'>Script</span></span>”"
        titre.in_a(href:"unan/home").in_h1
      end
    end

    def bind; binding() end
  end # << self
end
