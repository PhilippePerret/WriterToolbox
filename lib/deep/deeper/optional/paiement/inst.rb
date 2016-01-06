# encoding: UTF-8
=begin

Module de paiement

=end

# Ce module n'est accessible que si on est l'administrateur ou
# un utilisateur identifié. Dans tous les autres cas, il n'y a
# aucune raison de passer par là.
raise unless user.admin? || user.identified?

class SiteHtml
  class Paiement

    # ---------------------------------------------------------------------
    #   Instances SiteHtml::Paiement
    # ---------------------------------------------------------------------

    # {Float} Le montant du paiement
    # Il doit être défini dans le Hash qui est envoyé à la
    # méthode `make_transaction`
    attr_reader :montant

    # {String} L'objet du paiement, par exemple le paiement
    # de l'abonnement au site.
    # Doit absolument être défini dans le Hash qui est
    # envoyé à la méthode `make_transaction`
    attr_reader :objet

    # {String} Le token de la transaction
    # C'est la méthode qui le définit en utilisant la
    # tournure :
    #   @token = command.token
    # avec `command` qui est la transaction effectuée
    # Elle peut également le récupérer dans l'url au
    # retour du paiement
    attr_reader :token

    # {String} La description du paiement, au cas où
    attr_accessor :description

    # Instanciation du paiement
    # +montant+ Le montant du paiement à effectuer
    def initialize

    end

    # Pour les vues
    def bind; binding() end

    def sandbox?
      @is_sandbox ||= self.class::sandbox?
    end

    # {String} Le montant en version Paypal
    # C'est une version avec les centimes
    def montant_paypal
      @montant_paypal ||= begin
        case montant
        when Fixnum then "#{montant}.00"
        else "#{montant}"
        end
      end
    end

    def payer_id
      @payer_id ||= param(:PayerID) || param(:payer_id)
    end

    def data_key
      {
        PAYMENTREQUEST_0_CURRENCYCODE:    "EUR",
        PAYMENTREQUEST_0_PAYMENTACTION:   "SALE",
        CANCELURL:                        SiteHtml::Paiement::url_retour_cancel,
        RETURNURL:                        SiteHtml::Paiement::url_retour_ok
      }
    end

    # = Main =
    #
    # Méthode appelée quand on arrive sur la page. Elle commence par appeler
    # SetExpressCheckout pour définir le paiement, afin de définir l'action
    # du formulaire du bouton PayPal. Note : L'icarien n'est pas encore sur la
    # page de paiement, elle lui sera affichée à la fin de ce processus.
    #
    # +data+ {Hash} Doit contenir au minimum :montant, le montant du
    # paiement.
    def init data

      raise "Il faut fournir le montant du paiement en argument (:montant)" if data[:montant].nil?
      @montant = data.delete(:montant)

      command = Command::new(self, "Initialisation du paiement")
      # On ajoute les "données clés" que sont la devise, les
      # URL OK et Cancel etc.
      command << data_key

      command << {
        method:                 "SetExpressCheckout",
        localecode:             "FR",
        cartbordercolor:        "008080",
        paymentrequest_0_amt:   montant_paypal,
        paymentrequest_0_qty:   "1"
        # # Détails
        # l_paymentrequest_0_name0:    "Module d'apprentissage #{current_user.current_module.name}",
        # l_paymentrequest_0_number0:  "#{current_user.current_module.id[3..-1]}"
      }

      # Exécution de la requête Paypal, sur le site PayPal
      command.exec

      # En cas de failure, on affiche le message d'erreur
      raise command.error if command.failure?

      # On définit le numéro du ticket, par commodité en propriété
      # du paiement, en l'empruntant à la commande.
      @token = command.token

    rescue Exception => e
      error "Un problème est malheureusement survenu au cours de l'instanciation du paiement (#init) : #{e.message}"
      debug e.message
      debug e.backtrace.join("\n")
    end

    ##
    # Appelée quand le paiement a été effectué par l'Icarien sur
    # le site PayPal. Mais ce paiement n'est pas encore confirmé.
    #
    # C'est le retour du site Paypal quand l'Icarien a payé. Il faut
    # confirmer le paiement sur Paypal, et enregistrer le paiement
    # dans les données de l'Icarien.
    #
    def valider_paiement
      # Instancier une commande Paypal
      command = Command::new(self, "Validation du paiement effectué")

      # Paramètres de la transaction
      command << {
        method:         'DoExpressCheckoutPayment',
        token:          token,
        PayerID:        payer_id,
        currencycode:   details_paiement[:currencycode],
        amt:            details_paiement[:amt],
        PaymentAction:  "SALE"
      }
      # === Exécuter la requête ===
      command.exec
      # Test du résultat
      if command.success?

        # Enregistrement du paiement dans la base de données
        save_paiement
        # Envoi d'un mail à l'utilisateur pour lui confirmer
        # le paiement
        send_mail_to_user

        # S'il y a une méthode de fin de processus, il faut
        # l'appeler. Dans le cas contraire, on s'arrête là.
        after_validation_paiement if self.respond_to?(:after_validation_paiement)

        return true
      else
        return error "Une erreur s'est produite : #{command.response[:l_shortmessage0]} / #{command.response[:l_longmessage0]}"
      end

    rescue Exception => e
      error "Une erreur s'est malheureusement produite."
      debug e.message
      debug e.backtrace.join("\n")
      debug "\n"+ "="*80
      debug "Full command envoyée : #{command.request}"
      debug "# Réponse de l'opération : #{command.response.inspect}"
    end

    # ---------------------------------------------------------------------
    #
    #   MÉTHODES UTILITAIRES
    #
    # ---------------------------------------------------------------------

    ##
    # {Hash} Retourne le Hash des détails de l'opération de
    # paiement après les avoir demandés à Paypal
    def details_paiement
      # On ne donnera une réponse positive que si le retour est
      # successful.
      command = Command::new(self, "Récupération des détails de paiement")

      # Les paramètres de la transaction
      command << {
        method:         'GetExpressCheckoutDetails',
        token:          token,
        PayerID:        payer_id
      }

      # On soumet la requête et on retourne les détails de l'opération
      # sous forme de Hash
      # NOTE : Dans la forme original de la méthode sur l'atelier
      # Icare, c'était une commande "--insecure" qui était envoyée. Ici,
      # si on n'est pas dans le bac à sable, ce sera une requête normale
      # qui sera à surveiller.
      command.exec
      return command.response

    end

    # L'URL de retour quand OK
    def url_return  ; @url_return ||= self.class::url_retour_ok end
    # L'URL de retour quand annulation
    def url_cancel  ; @url_cancel ||= self.class::url_retour_cancel end

    # Paramètres d'authentification
    def params_authentify
      @params_authentify ||= begin
        account = PAYPAL[sandbox? ? :sandbox_account : :live_account]
        {
          'USER'      => CGI::escape( account[:username] ),
          'PWD'       => account[:password],
          'SIGNATURE' => account[:signature],
          'VERSION'   => "119"
        }
      end
    end

    def url_paypal
      @url_paypal ||= "https://www.#{sandbox? ? 'sandbox.' : ''}paypal.com/cgi-bin/webscr"
    end

  end # /Paiement
end # /SiteHtml
