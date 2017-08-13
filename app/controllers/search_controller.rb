class SearchController < ApplicationController
  def results
    term = params[:term].downcase ||= ''
    if term.present?
      @results = true
      @total_results = 0
      if is_date? term
        date = parse_date term
        @total_results += 1 if @show = Show.avail.where(date: date).includes(:venue).first
        @total_results += @other_shows.size if @other_shows = Show.avail.where('extract(month from date) = ?', date[5..6]).where('extract(day from date) = ?', date[8..9]).where('date != ?', date).includes(:venue).order('date desc').all
      else
        t = "%#{term}%"
        @songs = Song.relevant.where('lower(title) LIKE ?', t).order('title asc').all
        @venues = Venue.relevant.where('lower(name) LIKE ? OR lower(abbrev) LIKE ? OR lower(past_names) LIKE ? OR lower(city) LIKE ? OR lower(state) LIKE ? OR lower(country) LIKE ?', t, t, t, t, t, t).order('name asc').all
        @tours = Tour.where('lower(name) LIKE ?', t).order('name asc').all
        @tags = Tag.where('lower(name) LIKE ? OR lower(description) LIKE ?', t, t).order('name asc').all
        @total_results = @songs.size + @venues.size + @tours.size + @tags.size
      end
    else
      @results = false
    end
    render layout: false if request.xhr?
  end

  private

  def is_date?(str)
    if str =~ /^(\d{1,2})(\-|\/)(\d{1,2})(\-|\/)(\d{1,4})$/ or str =~ /^(\d{4})(\-|\/)(\d{1,2})(\-|\/)(\d{1,2})$/
      begin
        Date.parse str
        return true
      rescue
        return false
      end
    else
      return false
    end
  end

  def parse_date(str)
    # handle 2-digit year as in 3/11/90
    if str =~ /^(\d{1,2})(\-|\/)(\d{1,2})(\-|\/)(\d{1,2})$/
      zero = ($5.size == 1 ? '0' : '')
      year = ($5.to_i > 70 ? "19#{zero}#{$5}" : "20#{zero}#{$5}")
      str = "#{year}-#{$1}-#{$3}"
    end
    Date.parse(str).strftime("%Y-%m-%d")
  end
end
