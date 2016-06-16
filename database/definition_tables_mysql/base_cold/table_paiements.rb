# encoding: UTF-8
=begin

  Schéma de la table des paiements. C'est-à-dire les
  abonnements au site (PAS le programme UN AN UN SCRIPT).

=end
def schema_table_paiements
  <<-MYSQL
CREATE TABLE paiements
  (
    # ID
    # --
    # Identifiant du paiement.
    id INTEGER AUTO_INCREMENT,

    # USER_ID
    # -------
    # ID de l'user qui a fait le paiement
    user_id INTEGER NOT NULL,

    # OBJET_ID
    # --------
    # L'objet du paiement, par exemple "ABONNEMENT" pour un
    # abonnement au site.
    objet_id VARCHAR(200) NOT NULL,

    # MONTANT
    # -------
    # Montant en euros du paiement
    montant INTEGER(4) NOT NULL,

    # FACTURE
    # -------
    # Le numéro de facture, tel que renvoyé par
    # PayPal
    facture VARCHAR(32) NOT NULL,

    # CREATED_AT
    # ----------
    # Le timestamp du paiement
    created_at INTEGER(10) NOT NULL,

    # Clé primaire sur id
    PRIMARY KEY (id)
  );
  MYSQL
end
