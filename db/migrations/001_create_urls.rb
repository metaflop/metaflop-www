Sequel.migration do
  change do
    create_table(:urls) do
      primary_key :id
      DateTime :created_at
      String :short, size: 10
      String :params, text: true
    end
  end
end
