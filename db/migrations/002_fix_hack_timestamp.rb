Sequel.migration do
  change do
    set_column_default :hacks, :created_at, Sequel::CURRENT_TIMESTAMP
  end
end
