# Tutorial from: http://datamapper.org/docs/create_and_destroy.html
# See also: http://datamapper.org/getting-started.html
require 'data_mapper'

# If you want the logs displayed you have to do this before the call to setup
# log_level: a symbol representing the log level from 
#            {:off, :fatal, :error, :warn, :info, :debug}
# See: http://datamapper.rubyforge.org/dm-core/DataMapper/Logger.html
DataMapper::Logger.new($stdout, :debug)

DataMapper.setup( :default, "sqlite3://#{Dir.pwd}/zoo.db" )

  # An in-memory Sqlite3 connection:
  # DataMapper.setup(:default, 'sqlite::memory:')

  # A Sqlite3 connection to a persistent database
  # DataMapper.setup(:default, 'sqlite:///path/to/project.db')

  # A MySQL connection:
  # DataMapper.setup(:default, 'mysql://user:password@hostname/database')

  # A Postgres connection:
  # DataMapper.setup(:default, 'postgres://user:password@hostname/database')
#
class Zoo
  include DataMapper::Resource

  property :id,          Serial
  property :name,        String
  property :description, Text
  property :inception,   DateTime
  property :open,        Boolean,  :default => false
end

# full path!
DataMapper.auto_migrate! # 
# This will issue the necessary CREATE statements 
# (DROPing the table first, if it exists) to define 
# each storage according to their properties. 
# After auto_migrate! has been run, the database should 
# be in a pristine state. All the tables will be empty 
# and match the model definitions.
#
# This wipes out existing data, so we could also do:
#
#            DataMapper.auto_upgrade!
#
# This tries to make the schema match the model. It will 
# CREATE new tables, and add columns to existing tables. 
# It won't change any existing columns though (say, to add 
# a NOT NULL constraint) and it doesn't drop any columns. 
# Both these commands also can be used on an individual 
# model (e.g. Post.auto_migrate!)

# If you want to create a new resource with some given 
# attributes and then save it all in one go, we can use 
# the #create method:

zoo = Zoo.create(:name => 'The Glue Factory', :inception => Time.now)


# If the creation was successful, #create will return 
# the newly created DataMapper::Resource. If it failed, 
# it will return a new resource that is initialized with 
# the given attributes and possible default values declared 
# for that resource, but that's not yet saved. 
# To find out wether the creation was successful or not, 
# you can call #saved? on the returned resource. It will 
# return true if the resource was successfully persisted, 
# or false otherwise.

if zoo.saved? 
  puts "zoo saved #{zoo.inspect}"
else
  puts "zoo NOT saved #{zoo.inspect}"
end

# If we want to either find the first resource matching some 
# given criteria or just create that resource if it can't be 
# found, we can use #first_or_create.

zoo = Zoo.first_or_create(:name => 'The Glue Factory')

# This will first try to find a Zoo instance with the given 
# name, and if it fails to do so, it will return a newly 
# created Zoo with that name.

puts "zoo.saved? = #{zoo.saved?}"
puts "zoo = #{zoo.inspect}"

# If the criteria we want to use to query for the resource 
# differ from the attributes we need for creating a new 
# resource, we can pass the attributes for creating a new 
# resource as the second parameter to #first_or_create, 
# also in the form of a #Hash:

zoo = Zoo.first_or_create({ :name => 'The Glue Factory' }, 
                          { :inception => Time.now })

# This will search for a Zoo named 'The Glue Factory' and if 
# it can't find one, it will return a new Zoo instance with 
# its name set to 'The Glue Factory' and the inception set to 
# what has been Time.now at the time of execution. 
# You can see that for creating a new resource, both hash 
# arguments will be merged so we don't need to specify the 
# query criteria again in the second argument Hash that lists 
# the attributes for creating a new resource. 

puts "zoo.saved? = #{zoo.saved?}"
puts "zoo = #{zoo.inspect}"

# However, if we really need to create 
# the new resource with different values 
# from those used to query for it, the second Hash argument 
# will overwrite the first one.

zoo = Zoo.first_or_create({ :name => 'The Chocolat Factory' }, {
  :name      => 'Brooklyn Zoo',
  :inception => Time.now
})

# This will search for a Zoo named 'The Chocolat Factory' but 
# if it fails to find one, it will return a Zoo instance 
# with its name set to 'Brooklyn Zoo' and its inception set 
# to the value of Time.now at execution time.

puts "zoo.saved? = #{zoo.saved?}"
puts "zoo = #{zoo.inspect}"

