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
  acts_as_list 
end

class ListTest < Test::Unit::TestCase
  def setup
    @myItems = []
    @myItemsOriginal
    setup_db
    (1..4).each do |counter| 
      Article.create! :position => counter, :parent_id => 5 
      @myItems.push Article.last.id
    end
    @myItemsOriginal = @myItems.dup
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
  
  def test_reordering
    assert_equal @myItems, Article.where(:parent_id=> 5).order(:position).map(&:id)
    Article.find(2).move_lower
    assert_equal @myItems.move(1,2), Article.where(:parent_id => 5).order(:position).map(&:id)
    Article.find(2).move_higher
    @myItems = @myItemsOriginal.dup
    assert_equal @myItems, Article.where(:parent_id => 5).order(:position).map(&:id)
    Article.find(1).move_to_bottom
    assert_equal @myItems.move(0,-1), Article.where(:parent_id=> 5).order(:position).map(&:id)

    Article.find(1).move_to_top
    @myItems = @myItemsOriginal.dup
    assert_equal @myItems, Article.where(:parent_id=> 5).order(:position).map(&:id)

    #ListMixin.find(2).move_to_bottom
    #assert_equal [1, 3, 4, 2], ListMixin.where(:parent_id=> 5).order(:pos).map(&:id)

    #ListMixin.find(4).move_to_top
    #assert_equal [4, 1, 3, 2], ListMixin.where(:parent_id=> 5).order(:pos).map(&:id)

  end
end