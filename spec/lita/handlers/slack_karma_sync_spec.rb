require "spec_helper"

describe Lita::Handlers::SlackKarmaSync, :lita_handler,
  additional_lita_handlers: [Lita::Handlers::Karma::Chat, Lita::Handlers::Karma::Config] do

  after do
    Lita::Handlers::Karma::Chat.routes.clear
  end

  it { is_expected.to route_event(:slack_user_created).to(:update_karma_terms) }

  context 'interacting with Karma' do
    let!(:liz1) { Lita::User.create('U03BX9ZA9', name: 'Liz Lemon', mention_name: 'lizlemon') }
    let(:handler_config) { registry.config.handlers }
    let(:format_user_karma_term) { ->(user_id, user_name) { "@#{user_id} (#{user_name})" } }
    let(:term_normalizer) {
      ->(full_term) {
        term = full_term.to_s.strip.sub(/[<:]([^>:]+)[>:]/, '\1')
        user = Lita::User.fuzzy_find(term)

        if user
          format_user_karma_term.call(user.id, user.name)
        else
          term.downcase
        end
      }
    }

    before do
      handler_config.karma.cooldown = nil
      handler_config.karma.link_karma_threshold = nil
      handler_config.karma.term_normalizer = term_normalizer
      handler_config.slack_karma_sync.user_term_normalizer = format_user_karma_term
    end

    it "updates the user's karma and links to reflect their updated name" do
      send_message('lizlemon++')
      expect(replies.last).to eq('@U03BX9ZA9 (Liz Lemon): 1')

      send_message('tacos++')
      send_command('lizlemon += tacos')

      send_message('lizlemon~~')
      expect(replies.last).to eq('@U03BX9ZA9 (Liz Lemon): 2 (1), linked to: tacos: 1')

      slack_user = rename_user(liz1, name: 'Liz2 Lemmonn', mention_name: 'liz2')
      subject.update_karma_terms(slack_user: slack_user)

      send_message('liz2~~')
      expect(replies.last).to eq('@U03BX9ZA9 (Liz2 Lemmonn): 2 (1), linked to: tacos: 1')
    end

    def rename_user(user, name:, mention_name:)
      liz2 = Lita::User.create(liz1.id, name: name, mention_name: mention_name)
      double('SlackUser', id: liz2.id, name: liz2.mention_name, real_name: liz2.name)
    end
  end
end
