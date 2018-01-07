# encoding: UTF-8
=begin
  Table pour les updates

=end
def schema_table_updates
  <<-MYSQL
CREATE TABLE updates
  (
    id INTEGER AUTO_INCREMENT,

    # MESSAGE
    # -------
    # Le message humain de l'actualisation
    message TEXT NOT NULL,

    #  ROUTE
    # -------
    # Si l'actualisation concerne une page en particulier,
    # on peut indiquer ici sa route.
    route VARCHAR(255),

    #  TYPE
    # ------
    # Type de l'actualisation, son sujet.
    # cf. TYPES dans ./objet/site/lib/module/updates/contantes.rb
    type VARCHAR(20),

    #  OPTIONS
    # ---------
    # TODO: RÉDUIRE À 16 COLONNES
    # Bit 1 : Annonce (0: pas d'annonce, 1: Annonce pour les inscrits,
    # 2: annonce pour les abonnés, 3: annonce pour les auteurs UNAN)
    # 4: annonce aux analystes
    # 9: annonce seulement sur la page d'accueil
    # Si > 0, l'actualité est annoncé sur la page d'accueil
    options VARCHAR(32) DEFAULT '000000',

    created_at INTEGER(10) NOT NULL,
    updated_at INTEGER(10),

    PRIMARY KEY (id)
  );
  MYSQL
end
