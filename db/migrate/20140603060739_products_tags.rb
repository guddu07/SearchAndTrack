class ProductsTags < ActiveRecord::Migration
  def change
    create_table :products_tags, id: false do |t|
    	t.references :product
    	t.references :tag
    end
  end
end
