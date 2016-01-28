# encoding: UTF-8
class Forum
class << self

  # Retourne un Array dont le premier élément est la
  # clause WHERE (avec des "?") et le second élément est
  # la liste Array des valeurs des points d'interrogation
  #
  # Utilisé aussi bien par les posts que par les sujets
  def where_clause_from filter
    return [nil, nil] if filter.nil?
    arr_where   = Array::new
    arr_values  = Array::new


    if filter[:user_id] || filter[:user]
      # Messages (posts) seulement
      filter[:user_id] ||= filter[:user].id
      arr_where   << "user_id = ?"
      arr_values  << filter[:user_id]
    end

    if filter[:creator_id] || filter[:creator]
      # Sujets seulement
      filter[:creator_id] ||= filter[:creator].id
      arr_where   << "creator_id = ?"
      arr_values  << filter[:creator_id]
    end

    if filter[:created_after]
      arr_where   << "created_at >= ?"
      arr_values  << filter[:created_after]
    end
    if filter[:created_before]
      arr_where   << "created_at < ?"
      arr_values  << filter[:created_before]
    end
    if filter.has_key?(:valid)
      arr_where   << "options LIKE ?"
      arr_values  << (filter[:valid] ? '1%' : '0%')
    end

    if filter[:content]
      # Messages seulement
      arr_where   << "content LIKE ?"
      arr_values  << "%" + filter[:content].gsub(/</,'&lt;').gsub(/>/,'&gt;') + "%"
    end

    if filter[:name]
      # Sujets seulement
      arr_where   << "name LIKE ?"
      arr_values  << "%#{filter[:name]}%"
    end

    if filter[:categories]
      # Sujets seulement
      if filter[:categories].instance_of?(Fixnum)
        arr_where   << "categories = ?"
      else
        arr_where   << "categories IN ?"
      end
      arr_values  << filter[:categories]
    end



    [arr_where.join(' AND '), arr_values]
  end


end # << self
end #/Forum
