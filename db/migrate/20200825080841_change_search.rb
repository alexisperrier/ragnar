class ChangeSearch < ActiveRecord::Migration[5.2]
  def change

      remove_foreign_key :searches, name: "fk_rails_9ddb83a6e2"
      remove_foreign_key :searches, name: "fk_rails_e192b86393"
      remove_foreign_key :colvids, name: "fk_rails_53d2307ab1"
      remove_foreign_key :colvids, name: "fk_rails_676470ea2a"
      change_column :searches, :query, "json USING query::json"
      remove_column :searches, :user_id
  end
end
