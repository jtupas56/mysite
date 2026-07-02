class AddUserToVaults < ActiveRecord::Migration[8.1]
  def change
    # 1. Add column, allow NULL for now
    add_reference :vaults, :user, foreign_key: true, null: true

    # 2. Fix existing records
    reversible do |dir|
      dir.up do
        # Create a default system user if no user exists
        default_user = User.find_or_create_by!(email: "system@example.com") do |u|
          u.password = "password123"
          u.password_confirmation = "password123"
        end
        # Assign all vaults without a user to the default user
        Vault.where(user_id: nil).update_all(user_id: default_user.id)
      end
    end

    # 3. Now enforce NOT NULL
    change_column_null :vaults, :user_id, false
  end
end