class AddSearchToCollection < ActiveRecord::Migration[5.2]
  def change
      add_reference :colvids, :search, index: true, foreign_key: true
  end
end
