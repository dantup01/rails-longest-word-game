require 'open-uri'
require 'json'
require 'date'

class GamesController < ApplicationController
  def new
    @letters = generate_grid(9)
  end

  def score
    @word = params[:word]
    @grid = params[:grid]
    @start_time = params[:start_time].to_datetime
    @end_time = Time.now
    @result = run_game(@word, @grid, @start_time, @end_time)
    @time_taken = @result[:time].round(2)
    @score = @result[:score].to_i
    @message = @result[:message]
  end

  private

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end

  def english_word(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    read_file = open(url).read
    word_check = JSON.parse(read_file)
    return word_check['found']
  end

  def included_in_grid(attempt, grid)
    in_grid = attempt.upcase.chars.all? do |letter|
      (attempt.upcase.count(letter) <= grid.count(letter))
    end
    return in_grid
  end

  def compute_score(attempt, start_time, end_time)
    time_taken = end_time - start_time
    score = (attempt.length / time_taken) * 20
    return score
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: (end_time - start_time) }
    result[:score] = 0
    result[:message] = "Congratulations! Well Done!"
    if !english_word(attempt)
      result[:message] = "Sorry, this is not an English word. Please try again."
    elsif !included_in_grid(attempt, grid)
      result[:message] = "Your word is not in the grid provided."
    else result[:score] = compute_score(attempt, start_time, end_time)
    end
    return result
  end
end
