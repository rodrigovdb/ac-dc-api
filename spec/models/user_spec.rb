# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { create(:user, email: email, password: password) }

  let(:email) { 'rodrigovdb@gmail.com' }
  let(:password) { 'rapadura' }

  let(:current_date) { DateTime.new(2022, 12, 13, 14, 15, 16) }

  around do |example|
    Timecop.freeze(current_date) { example.run }
  end

  describe '.authenticate' do
    subject(:authenticated_user) { described_class.authenticate(auth_email, auth_password) }

    let(:auth_email) { user.email }
    let(:auth_password) { password }

    context 'whith valid credentials' do
      it { is_expected.to eq(user) }

      it do
        expect { authenticated_user }.to change { user.reload.authorization_token }
          .to(kind_of(String))
      end
    end

    context 'with email does not exist' do
      let(:auth_email) { 'inexistent@email.com' }

      it { is_expected.to be_falsey }
    end

    context 'with email does not exist' do
      let(:auth_password) { 'wrong-password' }

      it { is_expected.to be_falsey }
    end
  end

  describe '#valid_token?' do
    subject(:valid_token) { user.valid_token? }

    let(:generated_at) { current_date - 30.minutes }

    before do
      user.update(
        authorization_token: 'test-token',
        authorization_token_generated_at: generated_at
      )
    end

    context 'when token is valid' do
      it { is_expected.to be_truthy }
    end

    context 'when there is no token' do
      let(:generated_at) { nil }

      it { is_expected.to be_falsey }
    end

    context 'when token is expired' do
      let(:generated_at) { current_date - 61.minutes }

      it { is_expected.to be_falsey }
    end
  end

  describe '#authorization_token_expires_at' do
    subject(:authorization_token_expires_at) { user.authorization_token_expires_at&.to_datetime }

    context 'when authorization_token_generated_at is nil' do
      it { is_expected.to be_nil }
    end

    context 'when authorization_token_generated_at is present' do
      let(:generated_at) { current_date - 30.minutes }

      before do
        user.update(
          authorization_token: 'test-token',
          authorization_token_generated_at: generated_at
        )
      end

      it { is_expected.to eq(generated_at + 1.hour) }
    end
  end
end
