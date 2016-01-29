def post
  @post ||= site.objet
end
if param(:v) == "1"
  post.upvote
else
  post.downvote
end
redirect_to :last_route
