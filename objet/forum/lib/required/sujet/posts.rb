# encoding: UTF-8
class Forum
class Sujet

  def add_post post_id
    post_id = post_id.id if post_id.instance_of?(Forum::Post)
    @count = count + 1
    # Forum::table_sujets.update(id, {count:@count, last_post_id:post_id})
    set( count:@count, last_post_id:post_id )
  end

end #/Sujet
end #/Forum
