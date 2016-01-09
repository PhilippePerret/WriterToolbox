# encoding: UTF-8
=begin

Méthodes gérant la donnée `days_overview` du programme

cf. le fichier dev “Days-overview.md”

=end
class Unan
class Program

  # Valeur du days-overview, aperçu de tous les jours
  def days_overview
    @days_overview ||= DaysOverview::new(self)
  end

  # {Unan::Program::DaysOverview::Day} Retourne le jour
  # du days-overview du programme courant
  # +ijour+ {Fixnum} Index du jour, 1-start, de 1 à 365
  def day_overview ijour
    @all_days_overview[ijour] ||= days_overview.day(ijour)
  end

  # ---------------------------------------------------------------------
  #   Unan::Program::DaysOverview
  #   ---------------------------
  #   Gestion du days-overview du programme
  # ---------------------------------------------------------------------
  class DaysOverview
    attr_reader :program
    def initialize program
      @program = program
      @days = Array::new
    end

    def value
      @value ||= program.get(:days_overview)
    end

    # Modifie la valeur d'un jour day-overview
    # Ne pas sauver la donnée, le faire explicitement dans
    # la méthode qui le réclame (car on peut vouloir changer beaucoup
    # de jours à la suite, sans enregistrer chaque fois)
    def set_jour ijour, new_value
      offset_jour = (ijour - 1) * 2
      before = offset_jour == 0 ? "" : value[0..offset_jour-1]
      after  = value[offset_jour+2..-1] || ""
      @value = before + new_value + after
    end

    # Sauve la donnée days_overview dans la table
    def save
      program.set(days_overview: value)
    end

    # {Unan::Program::DaysOverview::Day] Retourne un jour du programme
    def day ijour
      @days[ijour] ||= Day::new(self, ijour)
    end

    # ---------------------------------------------------------------------
    #   Pour les instances de day-overview, c'est-à-dire le nombre
    #   en base 32 sur deux chiffres dans le days_overview
    # ---------------------------------------------------------------------
    class Day


        # Définition des Bits (il y en a 10 pour caractériser)
        B_ACTIF    = 1    # Bit ( 1) d'activité
        B_MAIL_DEB = 2    # Bit ( 2) de mail d'annonce
        B_CONF_DEB = 4    # Bit ( 3) de confirmation de démarrage par auteur

        B_MAIL_FIN = 128  # Bit ( 8) de mail de fin
        B_FORC_FIN = 256  # Bit ( 9) de fin forcée
        B_FIN      = 512  # Bit (10) de fin (forcée ou non)

      # {Unan::Program::DaysOverview} Instance du days-overview
      # du programme qui contient ce jour
      attr_reader :idays_overview

      # {Fixnum} Index du jour
      attr_reader :jour

      # {Fixnum} La valeur décimal de ce jour
      attr_writer :val10


      def initialize idays_overview, index_jour
        @idays_overview = idays_overview
        @jour           = index_jour
      end

      # ---------------------------------------------------------------------
      #   Toutes les méthodes pour tester les bits

      def actif?      ; value & B_ACTIF     > 0   end
      def mail_deb?   ; value & B_MAIL_DEB  > 0   end
      def conf_deb?   ; value & B_CONF_DEB  > 0   end
      def mail_fin?   ; value & B_MAIL_FIN  > 0   end
      def forc_fin?   ; value & B_FORC_FIN  > 0   end
      def fin?        ; value & B_FIN       > 0   end

      # ---------------------------------------------------------------------
      #
      # Toutes les méthodes pour ajouter une valeur de bit
      #
      # Elles sont toutes construites sur add_bit_<nom bite minuscuel sans B_>
      def add_bit_actif     ; add B_ACTIF     end
      def add_bit_mail_deb  ; add B_MAIL_DEB  end
      def add_bit_conf_deb  ; add B_CONF_DEB  end
      def add_bit_mail_fin  ; add B_MAIL_FIN  end
      def add_bit_forc_fin  ; add B_FORC_FIN  end
      def add_bit_fin       ; add B_FIN       end

      def remove_bit_actif     ; remove B_ACTIF     end
      def remove_bit_mail_deb  ; remove B_MAIL_DEB  end
      def remove_bit_conf_deb  ; remove B_CONF_DEB  end
      def remove_bit_mail_fin  ; remove B_MAIL_FIN  end
      def remove_bit_forc_fin  ; remove B_FORC_FIN  end
      def remove_bit_fin       ; remove B_FIN       end


      # Ajoute un valeur au nombre, souvent une
      # constante Unan::Program::DaysOverview::B_<...>
      # et l'enregistre dans la table, sauf si dont_save
      # et true
      def < valeur, saving = true
        unless self.val10 & valeur > 0
          self.val10 += valeur
          update_values saving
        end
      end
      alias :add :<

      def > valeur, saving = true
        if (self.val10 & valeur) > 0
          self.val10 -= valeur
          update_values saving
        end
      end
      alias :remove :>

      # Actualisation des valeurs en fonction de val10
      # Même dans le days_overview du programme
      def update_values saving = true
        @val32  = self.val10.to_s(32).freeze
        @valbin = self.val10.to_s(2).freeze
        idays_overview.set_jour jour, @val32
        idays_overview.save if saving
      end

      # Retourne la valeur décimal du jour
      # De 0 à 1023
      def val10
        @val10 ||= val32.to_i(32)
      end
      alias :value :val10

      # Retourne la valeur string dans la table du jour
      # De "00" (0 ou nil) à "vv" (1023)
      def val32
        @val32 ||= begin
          offset_jour = (jour - 1) * 2
          idays_overview.value[offset_jour..offset_jour+1] || "00"
        end
      end

      # La valeur binaire (juste pour débug ?)
      # de 0 à 1111111111
      def valbin
        @valbin ||= val10.to_s(2)
      end

    end #/Unan::Program::DaysOverview::DayOverview
  end #/Unan::Program::DaysOverview

end #/Program
end #/Unan
