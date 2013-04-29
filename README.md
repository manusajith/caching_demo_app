#Cache in Rails#

Web cache is a mechanism used for storing web documents such as HTML pages and images to reduce the bandwidth and server load. In Ruby on Rails there are mainly 3 type of caching used namely Page caching, Action Caching and Fragment Caching

#Page Caching#

In page caching whenever a request is sent by a user to the server, the web server would check for the generated cached page and if that exists it would be served. Hence the rails app wont have to process it again thereby saving bandwidth and avoids load on the server. This type of caching is lightning fast, but one main disadvantage of this is that this cant be used for caching every pages. As the requests dont go to the rails app, the authentication and access restrictions using `before_filter` wont work if page_caching is used.

Consider and example where a page relies on the users settings. If we cache this page, another user wont get the customized settings but only be able to get the cached copy of the page.

eg for Page caching:
```
Class HomeController < ActionController
  before_filter :authenticated_user!
  caches_page :index
  
  def index
    redirect_to articles_path if user_signed_in?
  end
 
end
```
In the above example if page caching is used then it will only serve the cached copy of the page, even if the user is not authenticated.
To expire the cache when an update is made, we will have to call an expire_page action
eg :

```
Class HomeController < ActionController
  before_filter :authenticated_user!
  caches_page :home
  
  def home
    redirect_to articles_path if user_signed_in?
  end
  
  def sign_out
    expire_page :action=> profile
    #sign_out the user
  end

end
```

An example app which uses page caching can be found [here](https://github.com/manusajith/caching_demo_app/tree/page_caching/ "Demo App")

In the above app you can find the cached pages for [article](https://github.com/manusajith/caching_demo_app/blob/page_caching/public/articles.html "article") and the [home page](https://github.com/manusajith/caching_demo_app/blob/page_caching/public/index.html "home page"). This would be served whenever a user refreshes the browser and as long as the cache isnt expired

#Action Caching#

In action caching the disadvantages of page caching wont be a problem as all the requests will be sent to the rails app via the web-server  Hence the authentication and access restrictions using the before_filters can be applied before serving a page. Action Caching is done similar to page caching in terms of code.
eg:
```
class ArticlesController < ApplicationController
  before_filter :authenticate_user!
  caches_action :index, :show
  
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def edit
    @article = Article.find(params[:id])
  end

  def create
    @article = Article.new(params[:article])
    respond_to do |format|
      if @article.save
        expire_action :action => [:index,:show]
        format.html { redirect_to @article, notice: 'Article was successfully created.' }
        format.json { render json: @article, status: :created, location: @article }
      else
        format.html { render action: "new" }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

end
```

In the above example the actions index and show are cached. Hence whenever a user views the index or show action, the cached copy will be sent to his browser. But we need to make sure that the cache is expired whenever a new article is added, edited or deleted. This can be done using the expire_action after a create action, update action and destroy method.

#Fragment Caching#

Fragment Caching is mainly used for dynamic pages. In this type of caching fragments of a page can be cached and expired.

Consider and example in which an article is posted to a blog and a reader wants to post a comment to it. Since the article is the same this can be cached while the comments will be dynamic in nature  as he posts his comment that should be displayed. In this case we can use fragment caching for posts

eg:
```
<% cache do %>
  <%= render article %>
<% end %>

<% @article.comments.each do |comments| %>
  <%= comments.user_name %>
  <%= comments.user_comment %>
<% end %>
```
Here the article would be cached while the comments wont.

#SQL Caching#

Sql Caching will cache any sql results performed by the Active Records or Data mappers so that if the same query is doesn't hit the database again and thereby decreasing the load time.
Eg: 
```
class ArticleController < ActionController
 
  def index
    @artilces = Article.all
 
    # Run the same query again
    @articles = Article.all # will pull the data from the memory and not from DB
  end
 
end
```

#Russian Doll Caching (Rails 4)#

In Russian Doll Caching nested fragment caches are used, so that the caches can be reused again. In Russian Doll caching, if a fragment changes at the top level then only that fragment is expired instead of expiring the whole fragment. Thus we can reuse that cache.

Eg:

```
class Article < ActiveRecord::Base
  has_many :comments
end

class Comments < ActiveRecord::Base
  belongs_to :articles, touch: true
end
```

The `touch` option to `belongs_to` model will make sure that whenever the article changes the cache will be updated for comments too.



PS: The [Demo App](https://github.com/manusajith/caching_demo_app/ "Demo App") was created using scaffolded code and is just meant for demonstrating the caching mechanism in rails. User authentication and UI wasnt give much importance. If someone has spare time and is willing to contribute the pullrequests are always welcome :)

Manu S Ajith

[Github](http://github.com/manusajith/ "Github") | [Twitter](http://twitter.com/manusajith/ "Twitter")
