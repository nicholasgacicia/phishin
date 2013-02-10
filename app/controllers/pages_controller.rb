class PagesController < ApplicationController

  def index
    redirect_to :years
  end

  def years
  end
  
  def songs
  end
  
  def cities
  end

  def venues
  end
  
  def liked
  end
  
  # Try to match the global URL "glob" to an entity
  def glob
    g = params[:glob]
    
    # Year?
    if g.match(/^\d{4}$/)
      if year g
        @year = g
        render :year_or_range
      else
        redirect_to :root
      end
    # Year range?
    elsif years = g.match(/^(\d{4})-(\d{4})$/)
      if year_range years[1], years[2]
        @year = g
        render :year_or_range
      else
        redirect_to :root
      end
    # Show date?
    elsif g.match(/^\d{4}\-\d{2}-\d{2}$/)
      if show g
        render :show
      else
        render :show_error
      end
    else
      # Song?
      if song g
        render :song
      # City?
      elsif city g
        render :city
      # Venue?
      elsif venue g
        render :venue
      else
        redirect_to :root
      end
    end
  end
  
  private
  
  def year(year)
    @shows = Show.during_year(year).includes(:tour).all
    @shows
  end
  
  def year_range(year1, year2)
    @shows = Show.between_years(year1, year2).includes(:tour).all
    @shows
  end
  
  def show(date)
    # Ensure valid date before touching database
    begin
       Date.parse(date)
    rescue
       return false
    end
    @show = Show.where(date: date).includes(:tracks).first
    @show
  end
  
  def song(slug)
    @song = Song.where(slug: slug).includes(:tracks).first
    @song
  end
  
  def venue(slug)
    @venue = Venue.where(slug: slug).includes(:shows).first
    @venue
  end
  
  def city(slug)
    #TODO
    false
  end
  
end