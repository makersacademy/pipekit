# Pipekit

Pipekit is a gem to interact with [Pipedrive](https://www.pipedrive.com) API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pipekit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pipekit

Pipekit expects a config file containing your api token and key-value mappings for custom pipedrive fields. Look at [example config](./spec/support/config.yml) to see the file structure.

Configure Pipekit with your config file:

    Pipekit.config_file_path = File.join("config", "pipedrive.yml")

You need to do once when Pipekit is loaded, the good place for it in the Rails project is `initializers`.

## Usage

The interface of Pipekit is organised around *repositories*. The available repositories are:

- Deal
- DealField
- Note
- Organization
- Person
- PersonField

### Resource repositories

Deal, Note, Organization and Person represent corresponding resources on Pipedrive. Repositories provide several methods for querying and changing these resources.

Methods available for all non-field repositories are:

- `all`
- `where`
- `find_by`
- `create`
- `update`

#### Examples

Get all deals

```ruby
deal_repo = Pipekit::Deal.new

deal_repo.all
```

Get all persons matching an attribute

```ruby
person_repo = Pipekit::Person.new

person_repo.where(name: "Mike")
```

Get the first deal matching an attribute

```ruby
deal_repo = Pipekit::Deal.new

deal_repo.find_by(id: 123)
```

Create a person

```ruby
person_repo = Pipekit::Person.new

person_repo.create({name: "John Doe", deal_id: 123})
```

Update a note

```ruby
note_repo = Pipekit::Note.new

note_repo.update(123, {content: "Hey"})
```

### Field repositories

Pipedrive stores custom fields as key-value pairs. E.g. when you add an "Address" field to Persons Pipderive will store it as something like "050280e9bed01e55e25532f0b6e6228c748bf994"

Methods available for field repositories (PersonField, DealField) are:

- `get_by_key`
- `get_by_name`
- `find_label`
- `find_values`

### Response object

`Pipekit::Response` is a hash-like object that performs an automatic conversion if Pipedrive IDs to meaningful field names.

```ruby
# pipedrive.yml
#
# fields:
#   person:
#     Emergency Contact: 345abd
#     T-Shirt Size: 567qwe
#
# field_values:
#   person:
#     T-Shirt Size:
#       "1": Small
#       "2": Medium
#       "3": Large

data = {"id" => 123, "345abd" => "+44123456789", "567qwe" => "1"}

person = Pipekit::Response.new(data)
person["Emergency Contact"]
  #=> +44123456789
person["T-Shirt Size"]
  #=> "Small"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pipekit. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

