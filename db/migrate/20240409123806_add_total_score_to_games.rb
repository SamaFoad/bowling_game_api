class AddTotalScoreToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :total_score, :integer, default: 0
  end
end
