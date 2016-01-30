# encoding: UTF-8
class SiteHtml

  # Table contenant les dates de dernières actions
  #   key: La clé de la table
  #   time:  Le timestamp (nombre secondes depuis 1 1 1970)
  # @usage: Utiliser la méthode `get_last_date(key)` et
  # `set_last_date(key, value)` pour définir et récupérer des valeurs
  def table_last_dates
    @table_last_dates ||= self.db.create_table_if_needed('site_hot', 'last_dates')
  end


  def get_last_date key, default_value = nil
    key = key.to_s
    res = table_last_dates.select(where:{key: key}).values.first
    res || default_value
  end
  alias :get_last_time :get_last_date

  # Enregistrement de la clé +key+ avec le temps +time+
  def set_last_date key, time = nil
    time ||= Time.now.to_i
    key = key.to_s
    table_last_dates.set(value:{time:time, key:key}, where:{key: key})
  end
  alias :set_last_time :set_last_date
end
