require 'spec_helper'

require 'arlj'
require 'temping'

RSpec.describe Arlj do
  Temping.create :problem do
    with_columns do |t|
      t.integer :book_id, references: nil
      t.integer :answer
    end
  end

  Temping.create :book do
    with_columns do |t|
      t.string :name
    end

    extend Arlj

    has_many :problems
  end

  before(:all) do
    @book = Book.create(name: 'job')
    (1..10).map do |n|
      @book.problems.create(answer: n)
    end
  end

  describe '#aggregate' do
    specify 'COUNT(*)' do
      problems_count = Book.aggregate(:problems, 'count(*)').pluck('problems_count').first
      assert{ problems_count == @book.problems.size }
    end

    specify 'sum(answer)' do
      problems_sum_answer = Book.aggregate(:problems, 'SUM(answer)').pluck('problems_sum_answer').first
      assert{ problems_sum_answer == @book.problems.sum(:answer) }
    end

    specify 'SUM(answer) => name' do
      sum = Book.aggregate(:problems, 'sum(answer)' => 'sum').pluck('sum').first
      assert{ sum == @book.problems.sum(:answer) }
    end

    specify 'FAKE(answer) raises error' do
      error = rescuing{ Book.aggregate(:problems, 'FAKE(answer)') }
      assert{ error }
    end

    specify 'COUNT(*) => count, SUM(answer) => sum' do
      array = Book.aggregate(:problems, 'count(*)' => 'count', 'sum(answer)' => 'sum').pluck('count', 'sum').first
      assert{ array[0] == @book.problems.size }
      assert{ array[1] == @book.problems.sum(:answer) }
    end
  end
end
