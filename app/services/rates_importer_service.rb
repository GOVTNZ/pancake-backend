# frozen_string_literal: true

class RatesImporterService
  def clear!(rating_year, council)
    RatesBill.joins(:property).by_rating_year(rating_year).by_council(council).delete_all
    RatesPayer.joins(:property).by_rating_year(rating_year).by_council(council).delete_all
    Property.where(rating_year: rating_year, council: council).delete_all
  end

  def import(row, rating_year, council)
    valuation, _rating_year, location, suburb, town_city,
      total_rates, total_water_rates, _order, _council_owner_id,
      _surname, _first_names, _confidential, current_owner_start_date = row
    if total_rates.blank?
      puts 'SKIPPING blank rates record'
      return
    end

    property = Property.find_by(valuation_id: valuation, rating_year: rating_year)
    if property.blank?
      property = Property.create!(
        council: council,
        valuation_id: valuation,
        location: ("#{location.gsub /"/, ''} " + "#{suburb} " + town_city.to_s).strip,
        suburb: suburb,
        town_city: town_city,
        rating_year: rating_year,
        meta: row.to_s
      )
    end
    rates_bill = RatesBill.find_by(property: property, rating_year: rating_year)

    if rates_bill.present?
      current_rates = rates_bill.total_rates.to_f.round(2)
      new_rates = (total_rates.to_f + total_water_rates.to_f).round(2)
      # raise 'mismatch total_rates' unless current_rates == new_rates
    else
      RatesBill.create!(
        property: property,
        rating_year: rating_year,
        total_rates: total_rates.to_f + total_water_rates.to_f,
        current_owner_start_date: current_owner_start_date
      )
    end
  end
end
