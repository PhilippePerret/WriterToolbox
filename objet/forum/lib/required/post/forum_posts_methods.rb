# encoding: UTF-8
=begin

  Toutes les méthodes qu'on peut utiliser en faisant :

      forum.posts.<methode>


=end
class Forum
  def posts ; @posts ||= Post end

class Post
  class << self

    # {StringHTML} Retourne la liste de tous les messages par sujets
    # @usage :  forum.posts.as_list
    def as_list
      Forum::Sujet::all.collect do |sid, isujet|
        (isujet.as_titre_in_listing_posts + isujet.listing_posts).in_li(class:'topic', id:"topic-#{sid}")
      end.join('')
    end

  end # << self
end #/Post
end #/Forum
