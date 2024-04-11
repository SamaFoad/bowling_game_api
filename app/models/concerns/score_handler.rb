module ScoreHandler
  def frame_score(roll1, roll2, roll3)
    if strike?(roll1)
      10 + strike_bonus(roll2, roll3)
    elsif spare?(roll1, roll2)
      10 + spare_bonus(roll3)
    else
      roll1.pins_knocked_down + (roll2&.pins_knocked_down || 0)
    end
  end

  def strike?(roll)
    roll.pins_knocked_down == 10
  end

  def spare?(roll1, roll2)
    roll1.pins_knocked_down + (roll2&.pins_knocked_down || 0) == 10
  end

  def strike_spare_not_completed?(roll1, roll2, roll3)
    (strike?(roll1) || (roll2.present? && spare?(roll1, roll2))) && (roll2.blank? || roll3.blank?)
  end

  def strike_spare_completed?(roll1, roll2, roll3)
    strike?(roll1) || (roll2.present? && spare?(roll1, roll2)) && (roll2.present? && roll3.present?)
  end

  def strike_bonus(roll2, roll3)
    (roll2&.pins_knocked_down || 0) + (roll3&.pins_knocked_down || 0)
  end

  def spare_bonus(roll3)
    roll3&.pins_knocked_down || 0
  end
end
