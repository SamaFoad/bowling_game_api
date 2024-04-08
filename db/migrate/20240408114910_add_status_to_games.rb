class AddStatusToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :status, :string, default: 'started'
    change_column_default :games, :status, from: nil, to: 'started'
  end
end
