# frozen_string_literal: true

require 'date'
require 'json'
require 'net/http'

# Controller
class GamesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
    @letters = generate_grid(10)
  end

  def score
    @letters = params[:letters].split('')
    @word = params[:word]
    @start_time = DateTime.parse(params[:start_time])
    @result = run_game(@word, @letters, @start_time, Time.now)
  end

  private

  def generate_grid(grid_size)
    grid = []
    grid_size.times do
      grid << ('A'..'Z').to_a.sample
    end
    grid
  end

  def validate_word(word)
    JSON.parse(Net::HTTP.get(URI("https://wagon-dictionary.herokuapp.com/#{word}")))['found']
  end

  def pluck_grid(grid, word)
    word.chars do |char|
      return false unless grid.include?(char)

      grid.delete_at(grid.index(char))
    end
    true
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time, score: 0 }
    if validate_word(attempt) == false
      result[:message] = "Sorry but #{attempt} doesn't seem to be a valid English word..."
    elsif pluck_grid(grid, attempt.upcase) == false
      result[:message] = "Sorry, but #{attempt.upcase} can't be built out of #{grid.join(', ')}"
    else
      result[:message] = "Congratulations! #{attempt.upcase} is a valid English word!"
      result[:score] = attempt.length / (end_time - start_time)
    end
    result
  end
end
