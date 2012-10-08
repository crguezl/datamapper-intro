# Associations
# Associations are a way of declaring relationships 
# between models, for example 
# a blog Post "has many" Comments, 
# or a Post belongs to an Author. 
# They add a series of methods to your models which allow 
# you to create relationships and retrieve related models 
# along with a few other useful features. Which records are 
# related to which are determined by their foreign keys.
#
# The types of associations currently in DataMapper are:
#
# DataMapper Terminology
# has n
# has 1
# belongs_to
# has n, :things, :through => Resource
# has n, :things, :through => :models
#
# Declaring Associations
# This is done via declarations inside your model class. 
# The class name of the related model is determined by 
# the symbol you pass in. For illustration, we'll add an 
# association of each type. 
# Pay attention to the pluralization or the related model's name.
#
require 'data_mapper'

DataMapper::Logger.new($stdout, :debug)

DataMapper.setup( :default, "sqlite3://#{Dir.pwd}/posts.db" )

class Post
  include DataMapper::Resource

  property :id, Serial

  has n, :comments
end

class Comment
  include DataMapper::Resource

  property :id,     Serial
  property :rating, Integer

  belongs_to :post  # defaults to :required => true

  def self.popular
    all(:rating.gt => 3)
  end
end

DataMapper.auto_migrate! # 

# The belongs_to method accepts a few options. 
# As we already saw in the example above, belongs_to 
# relationships will be required by default 
# (the parent resource must exist in order for the 
# child to be valid). You can make the parent resource 
# optional by passing :required => false as an option 
# to belongs_to.
