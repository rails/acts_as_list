require 'test/unit'

require 'rubygems'
gem 'activerecord', '>= 3.0.0'
require 'active_record'

require "#{File.expand_path('../init',File.dirname(__FILE__))}"

class Array
  def move(from, to)
    insert(to, delete_at(from))
  end
end

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :articles do |t|
      t.column :position, :integer
      t.column :parent_id, :integer
      t.column :parent_type, :string
      t.column :created_at, :datetime      
      t.column :updated_at, :datetime
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Article < ActiveRecord::Base
  acts_as_list :scope => :parent
end

class ListTest < Test::Unit::TestCase
  def setup
    @myItems = []
    setup_db
    (1..4).each do |counter| 
      Article.create! :position => counter, :parent_id => 5 
      @myItems.push Article.last.id
    end    
  end
  
  def teardown
    teardown_db
  end

  def test_methods_available_for_array
      myArray = []
      assert myArray.respond_to?(:move), true
  end
  
  def test_methods_available_for_list
    @article = Article.first
    assert @article.respond_to?(:move_to_bottom), true
    assert @article.respond_to?(:move_higher), true
  end
  
  def test_items_are_ordered
    assert_equal @myItems, Article.where(:parent_id=> 5).order(:position).map(&:id)
  end
  
  def test_move_lower
    Article.find(2).move_lower
    assert_equal @myItems.move(1,2), Article.where(:parent_id => 5).order(:position).map(&:id)
  end
  
  def test_move_higher
    Article.find(2).move_higher
    assert_equal @myItems.move(0,1), Article.where(:parent_id => 5).order(:position).map(&:id)
  end
  
  def test_move_to_top_and_bottom
    Article.find(1).move_to_bottom
    assert_equal @myItems.move(0,-1), Article.where(:parent_id=> 5).order(:position).map(&:id)
    Article.find(1).move_to_top
    assert_equal @myItems.move(-1,0), Article.where(:parent_id=> 5).order(:position).map(&:id)#
  end
  
  def test_nil_return
    assert_equal Article.find(2), Article.find(1).lower_item
    assert_nil Article.first.higher_item
    assert_equal Article.find(3), Article.find(4).higher_item
    assert_nil Article.last.lower_item

  end
end

class Post < Article
end

class Comment < Article
end

#those tests are just repetition with different "seeds"
#i think we can rip it out
class ListSubTest < Test::Unit::TestCase

  def setup
    @myItems = []
    setup_db
    (1..4).each do |i| 
      ((i % 2 == 1) ? Comment : Post).create! :position => i, :parent_id => 5000 
      @myItems.push Article.last.id
    end
  end

  def teardown
    teardown_db
  end
  
  def test_items_are_ordered
    assert_equal @myItems, Article.where(:parent_id=> 5000).order(:position).map(&:id)
  end
  
  def test_move_lower
    Article.find(2).move_lower
    assert_equal @myItems.move(1,2), Article.where(:parent_id => 5000).order(:position).map(&:id)
  end
  
  def test_move_higher
    Article.find(2).move_higher
    assert_equal @myItems.move(0,1), Article.where(:parent_id => 5000).order(:position).map(&:id)
  end
  
  def test_move_to_top_and_bottom
    Article.find(1).move_to_bottom
    assert_equal @myItems.move(0,-1), Article.where(:parent_id=> 5000).order(:position).map(&:id)
    Article.find(1).move_to_top
    assert_equal @myItems.move(-1,0), Article.where(:parent_id=> 5000).order(:position).map(&:id)#
  end
  
  def test_nil_return
    assert_equal Article.find(2), Article.find(1).lower_item
    assert_nil Article.first.higher_item
    assert_equal Article.find(3), Article.find(4).higher_item
    assert_nil Article.last.lower_item
  end

end
#class Article < ActiveRecord::Base
#  acts_as_list :column => "position", :scope => [:parent_id, :parent_type]  
#end
