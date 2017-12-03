Sequel.migration do
  change do
    create_table(:hacks) do
      primary_key :id
      column :victim_id, String, null: false, index: true
      column :attacker_id, String, null: true, index: true
      column :created_at, DateTime, null: false, default: 'now()'
    end
  end
end
