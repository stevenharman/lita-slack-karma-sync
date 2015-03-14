module Lita
  module Handlers
    class SlackKarmaSync < Handler
      TERMS_KEY = 'terms'.freeze
      ANYNAME_GLOB = '*'.freeze

      on :slack_user_created, :update_karma_terms

      config :user_term_normalizer do
        validate do |value|
           t('callable_required') unless value.respond_to?(:call)
        end
      end

      def update_karma_terms(payload)
        user_id = payload.fetch(:slack_user).id

        new_term = find_term(user_id)
        existing_term = find_existing_term_for(user_id)
        # use #eql? b/c Term#== isn't properly aliased. See:
        # https://github.com/jimmycuadra/lita-karma/pull/17
        return if existing_term.eql?(new_term)

        copy_links(from: existing_term, to: new_term)
        copy_karma(from: existing_term, to: new_term)
        existing_term.delete
      end

      private

      def find_existing_term_for(user_id)
        terms = karma_redis.zscan_each(TERMS_KEY, match: normalized_user_term(user_id)).to_a
        terms = terms.map { |term, _score|
          find_term(term, normalize: false)
        }

        fail "Found unexpected terms: #{}" if terms.size > 1

        terms.first || NoMatchingTerm.new
      end

      def copy_karma(from:, to:)
        karma_redis.zincrby(TERMS_KEY, from.own_score, to.to_s)
      end

      def copy_links(from:, to:)
        from.links.each do |linked_term|
          to.link(linked_term)
        end
      end

      def find_term(raw_term, normalize: true)
        Karma::Term.new(robot, raw_term, normalize: normalize)
      end

      def normalized_user_term(user_id)
        config.user_term_normalizer.call(user_id, ANYNAME_GLOB)
      end

      def karma_redis
        @karma_redis ||= Redis::Namespace.new('handlers:karma', redis: Lita.redis)
      end

      class NoMatchingTerm
        def eql?(other)
          self.class.equal?(other.class)
        end
        alias == eql?

        def hash
          self.class.hash
        end
      end
    end

    Lita.register_handler(SlackKarmaSync)
  end
end
