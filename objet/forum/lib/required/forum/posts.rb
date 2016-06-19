# encoding: UTF-8
class Forum

  # Rappel : Singleton

  # Retourne les x derniers messages
  # x est Forum::Post::nombre_by_default
  def last_posts as = :instances
    @last_posts ||= begin
      post_ids = Forum::table_posts.select(colonnes:[], where:"options LIKE '1%'", limit:Forum::Post::nombre_by_default, order:"created_at DESC").collect{|h|h[:id]}
      post_ids.collect do |pid|
        Forum::Post::new pid
      end
    end

    case as
    when :instances then @last_posts
    when :li        then @last_posts.collect{|p| p.as_li}.join
    end
  end

end #/Forum
