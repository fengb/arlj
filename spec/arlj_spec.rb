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
      expect(problems_count).to eq(@book.problems.size)
    end

    specify 'sum(answer)' do
      problems_sum_answer = Book.aggregate(:problems, 'SUM(answer)').pluck('problems_sum_answer').first
      expect(problems_sum_answer).to eq(@book.problems.sum(:answer))
    end

    specify 'SUM(answer) => name' do
      sum = Book.aggregate(:problems, 'sum(answer)' => 'sum').pluck('sum').first
      expect(sum).to eq(@book.problems.sum(:answer))
    end

    specify 'FAKE(answer)' do
      expect{Book.aggregate(:problems, 'FAKE(answer)')}.to raise_error
    end

    specify 'COUNT(*) => count, SUM(answer) => sum' do
      array = Book.aggregate(:problems, 'count(*)' => 'count', 'sum(answer)' => 'sum').pluck('count', 'sum').first
      expect(array[0]).to eq(@book.problems.size)
      expect(array[1]).to eq(@book.problems.sum(:answer))
    end
  end
end
