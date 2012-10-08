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

# We can also create a new instance of the model, update its 
# properties and then save it to the data store. 
# The call to #save will return true if saving succeeds, 
# or false in case something went wrong.

zoo = Zoo.new
zoo.attributes = { :name => 'The Paper Factory', :inception => Time.now }
zoo.save

puts "zoo.saved? = #{zoo.saved?}"
puts "zoo = #{zoo.inspect}"

# In this example we've updated the attributes using the 
# #attributes= method, but there are multiple ways of setting the 
# values of a model's properties.

zoo = Zoo.new(:name => 'Awesome Town Zoo')                  # Pass in a hash to the new method
zoo.attributes = { :name => 'No Fun Zoo', :open => false }  # Set multiple properties at once
zoo.name = 'Dodgy Town Zoo'                                 # Set individual property
zoo.save

puts "zoo.saved? = #{zoo.saved?}"
puts "zoo = #{zoo.inspect}"

# Just like #create has an accompanying #first_or_create method, 
# #new has its #first_or_new counterpart as well. The only 
# difference with #first_or_new is that it returns a new unsaved 
# resource in case it couldn't find one for the given query criteria. 
# Apart from that, #first_or_new behaves just like #first_or_create 
# and accepts the same parameters. 

# It is important to note that #save will save the complete loaded 
# object graph when called. This means that calling #save on a 
# resource that has relationships of any kind (established via 
# belongs_to or has) will also save those related resources, if 
# they are loaded at the time #save is being called. Related 
# resources are loaded if they've been accessed either for read 
# or for write purposes, prior to #save being called.

# Update
# We can also update a model's properties and save it with 
# one method call. #update will return true if the record 
# saves and false if the save fails, exactly like the #save method.

zoo.update(:name => 'Funky Town Municipal Zoo')


puts "zoo.saved? = #{zoo.saved?}"
puts "zoo = #{zoo.inspect}"

# One thing to note is that the #update method refuses to update 
# a resource in case the resource itself is #dirty? at this time.

zoo.name = 'Brooklyn Zoo' # makes it dirty?
puts "zoo.dirty? = #{zoo.dirty?}"
begin
  zoo.update(:name => 'Funky Town Municipal Zoo')
  # => DataMapper::UpdateConflictError: Zoo#update cannot be called 
  #    on a dirty resource
rescue
  puts "Error while updating zoo: #$!"
end

# We can also use #update to do mass updates on a model. 
# In the previous examples we've used 
#             DataMapper::Resource#update 
# to update a single resource. We can also use 
#             DataMapper::Model#update 
# which is available as a class method on our models. 
# Calling it will update all instances of the model 
# with the same values.

Zoo.update(:name => 'Funky Town Municipal Zoo')

# Now the database has something like:
# sqlite> select * from zoos;
# 1|Funky Town Municipal Zoo||2012-10-07T12:44:50+01:00|f
# 2|Funky Town Municipal Zoo||2012-10-07T12:44:50+01:00|f
# 3|Funky Town Municipal Zoo||2012-10-07T12:44:50+01:00|f
# 4|Funky Town Municipal Zoo|||f

# This sets all Zoo instances' name property to 
# 'Funky Town Municipal Zoo'. Internally it does 
# the equivalent of:
#       Zoo.all.update(:name => 'Funky Town Municipal Zoo')

Zoo.all.each do |r|
  puts r.inspect
end

# This shows that actually, #update is also available on 
# any DataMapper::Collection and performs a mass update on 
# that collection when being called. You typically retrieve 
# a DataMapper::Collection from either a call to SomeModel.all 
# or a call to a relationship accessor for any 1:n or m:n relationship.

# Destroy
# To destroy a record, we simply call its #destroy method. 
# It will return true or false depending if the record is 
# successfully deleted or not. 
# Here is an example of finding an existing record 
# then destroying it:

zoo = Zoo.get(2)

puts "Destroying #{zoo.inspect}"
b = zoo.destroy
puts "Destroyed" if b

# We can also use #destroy to do mass deletes on a model. 
# In the previous examples we've used DataMapper::Resource#destroy 
# to destroy a single resource. 
# We can also use DataMapper::Model#destroy which is available 
# as a class method on our models. Calling it will remove all 
# instances of that model from the repository.

puts "Destroying all!"
Zoo.destroy

zoos = Zoo.all
puts "zoos.length = #{zoos.length}"

# This deleted all Zoo instances from the repository. 
# Internally it does the equivalent of:
#                 Zoo.all.destroy
# This shows that actually, #destroy is also available on 
# any DataMapper::Collection and performs a mass delete on 
# that collection when being called. You typically retrieve 
# a DataMapper::Collection from either a call to SomeModel.all 
# or a call to a relationship accessor for any 1:n or 
# m:n relationship.

# Talking to your datastore directly
#
# Sometimes you may find that you need to execute a non-query 
# task directly against your database. For example, performing 
# bulk inserts might be such a situation.
#
# The following snippet shows how to insert multiple records 
# with only one statement on MySQL. It may not work with other 
# databases but it should give you an idea of how to execute 
# non-query statements against your own database of choice.

adapter = DataMapper.repository(:default).adapter
# Insert multiple records with one statement (MySQL)
#adapter.execute("INSERT INTO zoos (id, name) VALUES (1, 'Lion'), (2, 'Elephant')")
adapter.execute("INSERT INTO zoos (id, name) VALUES (1, 'Lion');")
adapter.execute("INSERT INTO zoos (id, name) VALUES (2, 'Elephant')")
# The interpolated array condition syntax works as well:
# adapter.execute('INSERT INTO zoos (id, name) VALUES (?, ?), (?, ?)', 1, 'Lion', 2, 'Elephant')

# sqlite> INSERT INTO zoos (description, name) VALUES('fierce', 'Lion'), ('big', 'Elephant');
# Error: near ",": syntax error
# sqlite> INSERT INTO zoos (description, name) VALUES('fierce', 'Lion');
# sqlite> select * from zoos;
# 5|Lion|fierce||f
# sqlite> INSERT INTO zoos (description, name) VALUES ('big', 'Elephant');
# sqlite> 

# How to insert several values in one row in sqlite:
# insert into zoos ('id', 'name') select 3, 'dog' union all select 4, 'cat';)
# insert into zoos ('id', 'name') select 6, 'rabbit' union all select 7, 'pig' union all select 8,'horse';)
