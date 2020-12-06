class CreateTrades < ActiveRecord::Migration[5.2]
  def change
    create_table :trades do |t|
      t.string :ticker
      t.integer :side
      t.float :price
      t.integer :quantity
      t.date :date
      t.references :portfolio, foreign_key: true

      t.timestamps
    end
  end
end
