# encoding: UTF-8
debug "-> console.rb"
raise "Section interdite" unless user.admin?

class SiteHtml
class Admin
  class Console
    class << self
      def current
        @current ||= begin
          new().init # return self
        end
      end
    end
    # include Singleton
    def init
      @messages = Array::new
      return self
    end
    def execute_code
      lines.each do |line|
        # On marque la ligne pour pouvoir savoir ce qui a produit
        # le résultat
        log line, :code
        case line
        when "vide table paiements", "vider table paiements"
          vide_table_paiements
        else
          log "LIGNE INCOMPRÉHENSIBLE", 'warning fort'
          error "Line injouable : `#{line}`"
        end
      end
    end

    #
    # AIDE
    #
    # À REMPLIR À MESURE QUE DES MÉTHODES S'AJOUTENT
    #
    def help
      <<-HTML
<dl class='small'>
  <dt>Pour soumettre le code de la console</dt>
  <dd>Jouer simplement la touche retour-chariot normale.</dd>
  <dt>`vide table paiements`</dt>
  <dd>Vider la table des paiements, c'est-à-dire les supprime tous. À utiliser seulement en offline…</dd>
</dl>
      HTML
    end

    # ---------------------------------------------------------------------
    #   Méthodes utilisables
    # ---------------------------------------------------------------------
    def vide_table_paiements
      if OFFLINE
        User::table_paiements.pour_away
        if User::table_paiements.count == 0
          log "Table des paiements vidée avec succès"
        else
          log "Bizarrement, la table des paiements ne semble pas vide…"
        end
      else
        log "Impossible de vider la table des paiements en ONLINE", 'warning fort'
      end

    end

    # ---------------------------------------------------------------------
    #   Méthodes fonctionnelles
    # ---------------------------------------------------------------------
    def has_code?
      code != nil
    end
    def lines
      @lines ||= begin
        code.gsub(/\r/,'').split("\n").collect do |line|
          line.strip!
          next nil if line == "" || line.start_with?('#')
          line
        end.compact
      end
    end
    def code
      @code ||= param(:console).nil_if_empty
    end

    def log mess, css = nil
      debug "-> log #{mess}"
      @messages << mess.in_div(class: css.to_s)
      debug "@messages : #{@messages.join}"
    end
    def output
      "Résultat de l'opération".in_h3 +
      @messages.join('')
    end
  end
end # /Admin
end # /SiteHtml
def console
  @console ||= SiteHtml::Admin::Console::current
end
console.execute_code if console.has_code?
debug "<- console.rb"
