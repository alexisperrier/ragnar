class AddFlagToSearch < ActiveRecord::Migration[5.2]
    def change
        add_column :searches, :behavior, :string, default: "static"
    end
end
