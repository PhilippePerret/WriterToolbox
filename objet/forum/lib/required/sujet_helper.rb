# encoding: UTF-8
class Forum
  class Sujet
    def as_titre_in_listing_messages
      "#{name}".in_div(class:'topic_titre')
    end
    # def listing_messages
    #   "Messages du sujet #{name}".in_div(class:'topic_messages')
    # end
  end # /Forum::Sujet
end # /Forum
