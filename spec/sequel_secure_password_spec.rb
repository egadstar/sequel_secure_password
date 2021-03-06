require 'spec_helper'

describe "model using Sequel::Plugins::SecurePassword" do
  subject(:user) { User.new }

  context "with empty password" do
    before { user.password = user.password_confirmation = "" }

    it { is_expected.not_to be_valid }
  end

  context "with whitespace password" do
    before { user.password = user.password_confirmation = "    "; }

    it { is_expected.not_to be_valid }
  end

  context "with nil password" do
    before { user.password = user.password_confirmation = nil }

    it { is_expected.not_to be_valid }
  end

  context "without setting a password" do
    it { is_expected.not_to be_valid }
  end

  context "without confirmation" do
    before { user.password = "foo" }

    it { is_expected.not_to be_valid }
  end

  context "having cost within password_digest" do
    before { user.password = "foo" }
    it {
      expect(BCrypt::Password.new(user.password_digest).cost).to eq(BCrypt::Engine::DEFAULT_COST)
    }
  end

  context "when password matches confirmation" do
    before { user.password = user.password_confirmation = "foo" }

    it { is_expected.to be_valid }
  end

  it "has an inherited instance variable :@cost" do
    expect(User.inherited_instance_variables).to include(:@cost)
  end

  it "has an inherited instance variable :@include_validations" do
    expect(User.inherited_instance_variables).to include(:@include_validations)
  end

  it "has an inherited instance variable :@digest_column" do
    expect(User.inherited_instance_variables).to include(:@digest_column)
  end

  context "when validations are disabled" do
    subject(:user_without_validations) { UserWithoutValidations.new }

    before do
      user_without_validations.password = "foo"
      user_without_validations.password_confirmation = "bar"
    end

    it { is_expected.to be_valid }
  end

  describe "#authenticate" do
    let(:secret) { "foo" }
    before { user.password = secret }

    context "when authentication is successful" do
      it "returns the user" do
        expect(user.authenticate(secret)).to eq(user)
      end
    end

    context "when authentication fails" do
      it { expect(user.authenticate("")).to eq(nil) }
    end
  end

  describe "with cost option" do
    subject(:highcost_user) { HighCostUser.new }
    context "having cost within password_digest" do
      before { highcost_user.password = "foo" }
      it {
        expect(BCrypt::Password.new(highcost_user.password_digest).cost).to eq(12)
      }
    end
  end

  describe "with digest column option" do
    subject(:digestcolumn_user) { UserWithAlternateDigestColumn.new }
    context "having an alternate digest column" do
      before { digestcolumn_user.password = "foo" }
      it {
        expect(BCrypt::Password.new(digestcolumn_user.password_hash)).to eq("foo")
      }
    end
  end

  describe "ineritance" do
    it { expect { Class.new(UserWithAlternateDigestColumn) }.not_to raise_error }
  end
end
