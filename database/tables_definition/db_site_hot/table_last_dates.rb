# encoding: UTF-8
=begin

Définition du schéma de la table qui conserve les dates de
dernière action. Par exemple le timestamp du dernier check des messages
forum par le cron-job
=end
def schema_table_site_hot_last_dates
  @schema_table_site_last_dates ||= {

    key:  {type:"VARCHAR(255)", constraint:"NOT NULL"},

    time:  {type:"INTEGER(10)", constraint:"NOT NULL"}

  }
end
