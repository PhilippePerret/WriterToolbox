# encoding: UTF-8
class Forum
class Sujet

  def as_titre_in_listing_posts
    "#{name}".in_div(class:'topic_titre')
  end

  # def listing_posts
  #   "Messages du sujet #{name}".in_div(class:'topic_messages')
  # end

end # /Sujet
end # /Forum
