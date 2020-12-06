class CreateMarketData < ActiveRecord::Migration[5.2]
  def change
    create_table :market_data do |t|
      t.date :date
      t.string :ticker
      t.float :open
      t.float :high
      t.float :low
      t.float :close
      t.float :adjusted_close
      t.integer :volume
      t.float :dividend_amount
      t.float :split_coefficient
    end
  end
end
