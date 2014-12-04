# Arlj - ActiveRecord Left Join

Make left joins feel like first-class citizens.

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
puts Parent.arlj(:children).group('records.id').select('COUNT(children.id)').to_sql
=> SELECT COUNT(children.id)
     FROM "parents"
     LEFT OUTER JOIN "children"
                  ON "children"."parent_id" = "parents"."id"
    GROUP BY records.id
```

`arlj` is purposely low level to be extra chainable.

Arlj also adds an aggregation syntax:

```ruby
Parent.arlj_aggregate(:children, 'COUNT(*)', 'SUM(col)' => 'total').select('children_count', 'total').to_sql
=> SELECT children_count
        , total
     FROM "parents"
     LEFT OUTER JOIN (SELECT "children"."parent_id"
                           , COUNT("children"."id") AS children_count
                           , SUM("children"."col") AS total
                        FROM "children"
                       GROUP BY "children"."parent_id") arlj_aggregate_children
                  ON arlj_aggregate_children."parent_id" = "parents"."id"
```

`arlj_aggregate` currently uses a subquery to hide its aggregation. It's not the
most efficient implementation but it does offer a much better chaining
experience than using `group` at the top level.

Arlj can also alias `arlj` and `arlj_aggregate` to `left_joins` and
`left_joins_aggregate` respectively:

```ruby
class Parent < ActiveRecord::Base
  extend Arlj::LeftJoins
end

Parent.left_joins(:children).group('records.id').select('COUNT(children.id)')
Parent.left_joins_aggregate(:children, 'COUNT(*)', 'SUM(col)' => 'total')
```

## TODO

* Relations with conditions
* `LEFT JOIN [...] ON`
* `has_and_belongs_to_many`
* `has_many :through =>`

## Contributing

1. Fork it ( https://github.com/fengb/arlj/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
