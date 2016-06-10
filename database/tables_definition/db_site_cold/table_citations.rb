# encoding: UTF-8
=begin
  Table pour les updates

=end
def schema_table_site_cold_citations
  @schema_table_site_cold_citations ||= {

    id:  {type:'INTEGER', constraint:'PRIMARY KEY AUTOINCREMENT'},
    citation:     {type: 'TEXT', constraint: 'NOT NULL'},
    auteur:       {type:'VARCHAR(255)', constraint: 'NOT NULL'},
    source:       {type:'TEXT'},
    description:  {type: 'TEXT'},
    # Le lien bitly pour la citations
    bitly:        {type:'VARCHAR(50)'},
    # La dernière fois où la citation a été utilisée,
    # pour un tweet ou pour un mail
    last_sent:    {type:'INTEGER(10)'},
    created_at:   {type: 'INTEGER(10)'}

  }
end
