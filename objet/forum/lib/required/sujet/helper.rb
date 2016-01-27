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


    # {StringHTML} Un formulaire pour ajouter un sujet
    def new_sujet_form
      <<-HTML
  <form action="forum/new_topic" method="POST" class='small'>
    <div class="row">
      <span class="value"><input type="text" name="new_topic_name" placeholder="Sujet" value="" class="w300" /></span>
      <input type="submit" value="Initier ce nouveau sujet" class='btn' />
    </div>
  </form>

      HTML
    end
end # /Forum
