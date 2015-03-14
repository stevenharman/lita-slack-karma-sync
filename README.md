# Lita + Slack + Karma? You need to Sync!

Are you a Slack user? And does your team also use `lita-karma`? This plugin can
be used to keep your karma terms synced up with your Slack name.

### What's that now?

When using Slack and `lita-karma` you can give another user, or any term in the world, some karma like so:

```
> lizlemon++
> Litabot: lizlemon: 40
> computers--
> Litabot: computers: -10
> ruby~~
> Litabot: ruby: 12 (15), linked to: rubby: 3
```

And that works great for general terms, but there can be many ways to address a
user. "Liz Lemon" from the above example could be addressed in any of the
following ways:

* her mention name: `> lizlemon++`
* her mention name preceded with "`@`": `> @lizlemon++`
* her Slack UUID: `> U03BX9ZA9++`
* her Slack UUID preceded with "`@`": `> @U03BX9ZA9++`
* her full name with a "`:`" delimiters: `> :Liz Lemon:++`
* And each of the above could different based on capitalization!

The problem is these all become unique "Karma Terms" and Liz Lemon's karma has
been spread over a number of terms. To combat this, you can use `lita-karma`'s
`term_normalizer` to normalize to a single, consistent "term" for users. The
Slack UUID is a great choice for that. The wrinkle then is that you're left
with this:

```
> lizlemon++
> Litabot: U03BX9ZA9: 41
> Litabot karma
> Litabot:
    U09BZ9AF7: 45
    U08FA0EX1: 43
    tacos: 42
    U03BX9ZA9: 41
```

Who are those users? That's where this plugin can help! :thumbsup:

## Installation

Add `lita-slack-karma-sync` to your Lita instance's Gemfile:

``` ruby
gem "lita-slack-karma-sync"
```

## Configuration

In your `lita_config.rb`:

1. Create a `proc` that will normalize a given UUID and name to a consistent
   string. Something like this:

    ```ruby
    normalized_karma_user_term = ->(user_id, user_name) {
      "@#{user_id} (#{user_name})" #+> @UUID (Liz Lemon)
    }
    ```

1. Configure `lita-karma`'s `term_normalizer` to try to find a user for the
   "term", and then normalize them via the proc defined above.

    ```ruby
    config.handlers.karma.term_normalizer = lambda do |full_term|
      term = full_term.to_s.strip.sub(/[<:]([^>:]+)[>:]/, '\1')
      user = Lita::User.fuzzy_find(term)

      if user
        normalized_karma_user_term.call(user.id, user.name)
      else
        term.downcase
      end
    end
    ```

1. Tell `lita-slack-karma-sync` to use the same proc to normalize user terms:

  ```ruby
  config.handlers.slack_karma_sync.user_term_normalizer = normalized_karma_user_term
  ```

## Usage

Give folks karma!

```
> lizlemon++
> Litabot: @U03BX9ZA9 (Liz Lemon): 43
> @lizlemon++
> Litabot: @U03BX9ZA9 (Liz Lemon): 44
> liz++
> Litabot: @U03BX9ZA9 (Liz Lemon): 45
> :Liz Lemon:++
> Litabot: @U03BX9ZA9 (Liz Lemon): 46
> Litabot karma
> Litabot:
    @U03BX9ZA9 (Liz Lemon): 46
    @U09BZ9AF7 (Tracy Jordan): 45
    tacos: 42
    @U08FA0EX1 (Jack Donaghy): 41
```

## License

See the [LICENSE](LICENSE) file.
