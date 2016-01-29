# encoding: UTF-8
class Forum
class Sujet

  def as_titre_in_listing_posts
    "#{name}".in_div(class:'topic_titre')
  end

end # /Sujet
end # /Forum
