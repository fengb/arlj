# Arlj - ActiveRecord Left Join [![Travis CI](https://travis-ci.org/fengb/arlj.svg?branch=master)](https://travis-ci.org/fengb/arlj)

Make left joins feel like first-class citizens in ActiveRecord.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'arlj'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install arlj

## Usage

Load Arlj into your class:

```ruby
class Parent < ActiveRecord::Base
  extend Arlj
end
```

Or extend all of ActiveRecord models:

```ruby
ActiveRecord::Base.extend Arlj
```

Then begin to left join!

```ruby
puts Parent.left_joins(:children).group('records.id').select('COUNT(children.id)').to_sql
=> SELECT COUNT(children.id)
     FROM "parents"
     LEFT OUTER JOIN "children"
                  ON "children"."parent_id" = "parents"."id"
    GROUP BY records.id
```

`left_joins` is purposely low level for maximum control.

Arlj has an aggregation method that is higher level and generally easier to use:

```ruby
Parent.left_joins_aggregate(:children, 'COUNT(*)').to_sql
=> SELECT "parents".*
     FROM "parents"
     LEFT OUTER JOIN (SELECT "children"."parent_id"
                           , COUNT("children"."id") AS children_count
                        FROM "children"
                       GROUP BY "children"."parent_id") arlj_aggregate_children
                  ON arlj_aggregate_children."parent_id" = "parents"."id"
```

Supported aggregation functions are `COUNT()`, `SUM()`, `AVG()`, `MIN()`, and `MAX()`.

The aggregation column has a default name of `{table}_{function}_{column}` which
is easily renamed:

```ruby
Parent.left_joins_aggregate(:children, 'SUM(age)' => 'ekkekkekkekkeptangya').to_sql
=> SELECT "parents".*
     FROM "parents"
     LEFT OUTER JOIN (SELECT "children"."parent_id"
                           , SUM("children"."age") AS ekkekkekkekkeptangya
                        FROM "children"
                       GROUP BY "children"."parent_id") arlj_aggregate_children
                  ON arlj_aggregate_children."parent_id" = "parents"."id"
```

Since Arlj uses a sub-select, you can easily chain additional queries:

```ruby
Parent.left_joins_aggregate(:children, 'COUNT(*)').select('children_count').to_sql
=> SELECT children_count
     FROM "parents"
     LEFT OUTER JOIN (SELECT "children"."parent_id"
                           , COUNT("children"."id") AS children_count
                        FROM "children"
                       GROUP BY "children"."parent_id") arlj_aggregate_children
                  ON arlj_aggregate_children."parent_id" = "parents"."id"
```

Arlj also supports some basic where clauses:

```ruby
Parent.left_joins_aggregate(:children, 'COUNT(*)', where: {age: 1..5}).to_sql
=> SELECT "parents".*
     FROM "parents"
     LEFT OUTER JOIN (SELECT "children"."parent_id"
                           , COUNT("children"."id") AS children_count
                        FROM "children"
                       WHERE ("children"."age" BETWEEN 1 AND 5)
                       GROUP BY "children"."parent_id") arlj_aggregate_children
                  ON arlj_aggregate_children."parent_id" = "parents"."id"
```

If you prefer, you may also use `arlj` and `arlj_aggregate` instead of
`left_joins` and `left_joins_aggregate` respectively. To prevent potential
naming conflicts, use `Arlj::Base` instead:

```ruby
class Parent < ActiveRecord::Base
  extend Arlj::Base
end
```

**Arlj** has an experimental flag that uses the **memoist** gem to memoize the
generated join SQL:

```ruby
Arlj.memoize!
```

This has not been proven to be faster.

## Gotchas

* Since `left_joins_aggregate` uses a sub-select for its aggregation, it can
  underperform a better optimized query.

* When `left_joins_aggregate` joins zero records, the aggregate column is NULL.
  To operate correctly on these columns, please use `COALESCE(col, 0)`.

## TODO

* `left_joins(nested: :relations)`
* `left_joins_aggregate([...], merge: User.active)`
* `has_and_belongs_to_many`
* `has_many :through =>`

## Contributing

1. Fork it ( https://github.com/fengb/arlj/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
