# encoding: UTF-8
=begin
  Table pour les tweets permanent
  Cf. Manuel Divers > Twitter

=end
def schema_table_site_cold_permanent_tweets
  @schema_table_site_cold_permanent_tweets ||= {
    # Note : la propriété ID est automatiquement ajoutée

    # Le message du tweet (intégral)
    message:    {type:"VARCHAR(140)", constraint:"NOT NULL"},

    # Le lien bitly qui conduit à la page
    bitlink:    {type:"VARCHAR(100)"},

    # Le nombre de fois où ce tweet a été envoyé
    count:      {type:"INTEGER"},

    # La date de dernier envoi du tweet
    last_sent:  {type:"INTEGER(10)", constraint: "NOT NULL"},

    # Créaation du tweet permanent
    created_at:  {type:"INTEGER(10)", constraint:"NOT NULL"},
    # Modification du tweet permanent
    updated_at:  {type:"INTEGER(10)", constraint:"NOT NULL"}
  }
end
