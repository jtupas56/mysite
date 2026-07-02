class AddUserToVaults < ActiveRecord::Migration[8.1]
  def change
    # 1. Add the reference, but allow null temporarily
    add_reference :vaults, :user, foreign_key: true, null: true

    # 2. Use reversible block to assign existing vaults to a default user
    reversible do |dir|
      dir.up do
        # Find or create a system user to own the orphan vaults
        default_user = User.find_or_create_by!(email: "system@example.com") do |user|
          user.password = "password123"
          user.password_confirmation = "password123"
        end
        # Assign all vaults that have no user
        Vault.where(user_id: nil).update_all(user_id: default_user.id)
      end
    end

    # 3. Now enforce the NOT NULL constraint
    change_column_null :vaults, :user_id, false
  end
end