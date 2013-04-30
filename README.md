#Cache in Rails#

Web cache is a mechanism used for storing web documents such as HTML pages and images to reduce the bandwidth and server load. In Ruby on Rails there are mainly 3 types of caching used namely Page caching, Action Caching and Fragment Caching

#Page Caching#

In page caching whenever a request is sent by a user to the server, the web server would check for the generated cached page and if that exists it would be served. Hence the rails app won't have to process it again thereby saving bandwidth and avoids load on the server. This type of caching is lightning fast, but one main disadvantage of this is that this can't be used for caching every page. As the requests don't go to the rails app, the authentication and access restrictions using `before_filter` wont work if page caching is used.

Consider an example where a page relies on the user's settings. If we cache this page, another user won't get the customized settings but only be able to get the cached copy of the page.

eg for Page caching:

```
Class UserController < ActionController

  caches_page :profile

  def profile
    @user = current_user
  end

end
```

To expire the cache when an update is made, we will have to call an `expire_page` action
eg :

```
Class UserController < ActionController

  caches_page :profile

  def profile
    @user = current_user
  end

  def update
    expire_page :action=> profile
  end

end
```


#Action Caching#

In action caching the disadvantages of page caching won't be a problem as all the requests will be sent to the rails app via the web-server  Hence the authentication and access restrictions using the before_filters can be applied before serving a page. Action Caching is done similar to page caching in terms of code.
eg:

```
class UserController < ActionController

  before_filter :authenticate
  caches_action :profile

  def profile
    @user = current_user
  end

  def update
    expire_action :action => :profile
  end

end
```


#Fragment Caching#

Fragment Caching is mainly used for dynamic pages. In this type of caching fragments of a page can be cached and expired.

Consider an example in which an article is posted to a blog and a reader wants to post a comment to it. Since the article is the same this can be cached while the comments will be dynamic in nature  as he posts his comment that should be displayed. In this case we can use fragment caching for posts

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

SQL Caching will cache any SQL results performed by the Active Records or Data mappers so that if the same query is doesn't hit the database again and thereby decreasing the load time.
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

In Russian Doll Caching nested fragment caches are used, so that the caches can be reused again. In Russian Doll caching, if a fragment change at the top level then only that fragment is expired instead of expiring the whole fragment. Thus we can reuse that cache.

Eg:
```
class Article < ActiveRecord::Base
  has_many :comments
end

class Comments < ActiveRecord::Base
  belongs_to :articles, touch: true
end
```
The `touch` option for `belongs_to` model will make sure that whenever the article changes the cache will be updated in the comments too.

To demonstrate the concepts of caching in rails I have made a simple blog hack. Here the index action in home_controller.rb will render home page if the users aren't signed in else the signed in users will be redirected to the articles index action, where the articles will be displayed. In order to perform page caching, just add `caches_page` to the the home_controller.rb

Eg:
```
class HomeController < ApplicationController
  caches_page :index

  def index
    redirect_to articles_path if user_signed_in?
  end

end
```

An example of action caching can be found on the articles_controller.rb, where we can perform caching on the index, show actions.
Here as long as a new article is posted, edited or destroyed the contents of the index and show will remain the same. Hence we action caching would be the best in this case.

Eg:

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

end
```

But we need to make sure that the cache is expired whenever an article changes. So we also need to add `expire_action` to actions in articles_controller.rb

Eg:

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

  def create
    @article = Article.new(params[:article])
    if @article.save
      expire_action :action => [:index,:show] #expire the cache whenever a new article is posted
    end
  end

end
```

The index action also uses the  SQL caching mechanism in rails. The `Article.all` will run an Active Record query to fetch all the articles from the database and will create a cache for this query. If the same query is repeated the cached result will be used instead of querying the database again.


#What happens when inappropriate caching is used ?#

Consider the case, when page caching was used for the index action instead of action caching in the articles_controller.rb. Whenever a user clicks on the index link, a cached copy if the index page would be rendered to him, even if he is not signed in. Thus the purpose of authentication will be lost if inappropriate caching methods are used for your actions.


You can find the whole app at [github](https://github.com/manusajith/caching_demo_app/ "Demo App").

PS: The Demo App was created using scaffolded code and is just meant for demonstrating the caching mechanism in rails. User authentication and UI wasn't give much importance. If someone has spare time and is willing to contribute the pull-requests are always welcome :)

--
<br>
Manu S Ajith
<br>
[GitHub](https://github.com/manusajith/ "Github") | [Twitter](https://twitter.com/manusajith/ "Twitter")


