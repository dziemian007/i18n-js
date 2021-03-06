require "spec_helper"

describe I18n::JS::Utils do

  describe ".strip_keys_with_nil_values" do
    subject { described_class.strip_keys_with_nil_values(input_hash) }

    context 'when input_hash does NOT contain nil value' do
      let(:input_hash) { {a: 1, b: { c: 2 }} }
      let(:expected_hash) { input_hash }

      it 'returns the original input' do
        is_expected.to eq expected_hash
      end
    end
    context 'when input_hash does contain nil value' do
      let(:input_hash) { {a: 1, b: { c: 2, d: nil }, e: { f: nil }} }
      let(:expected_hash) { {a: 1, b: { c: 2 }, e: {}} }

      it 'returns the original input with nil values removed' do
        is_expected.to eq expected_hash
      end
    end
  end

  context "hash merging" do
    it "performs a deep merge" do
      target = {:a => {:b => 1}}
      result = described_class.deep_merge(target, {:a => {:c => 2}})

      result[:a].should eql({:b => 1, :c => 2})
    end

    it "performs a banged deep merge" do
      target = {:a => {:b => 1}}
      described_class.deep_merge!(target, {:a => {:c => 2}})

      target[:a].should eql({:b => 1, :c => 2})
    end
  end

  describe ".deep_reject" do
    it "performs a deep keys rejection" do
      hash = {:a => {:b => 1}}

      result = described_class.deep_reject(hash) { |k, v| k == :b }

      result.should eql({:a => {}})
    end

    it "performs a deep keys rejection prunning the whole tree if necessary" do
      hash = {:a => {:b => {:c => {:d => 1, :e => 2}}}}

      result = described_class.deep_reject(hash) { |k, v| k == :b }

      result.should eql({:a => {}})
    end


    it "performs a deep keys rejection without changing the original hash" do
      hash = {:a => {:b => 1, :c => 2}}

      result = described_class.deep_reject(hash) { |k, v| k == :b }

      result.should eql({:a => {:c => 2}})
      hash.should eql({:a => {:b => 1, :c => 2}})
    end
  end

  describe ".deep_key_sort" do
    let(:unsorted_hash) { {:z => {:b => 1, :a => 2}, :y => 3} }
    subject { described_class.deep_key_sort(unsorted_hash) }

    it "performs a deep keys sort without changing the original hash" do
      should eql({:y => 3, :z => {:a => 2, :b => 1}})
      unsorted_hash.should eql({:z => {:b => 1, :a => 2}, :y => 3})
    end
  end

  describe ".scopes_match?" do
    it "performs a comparison of literal scopes" do
      described_class.scopes_match?([:a, :b], [:a, :b, :c]).should_not eql true
      described_class.scopes_match?([:a, :b, :c], [:a, :b, :c]).should eql true
      described_class.scopes_match?([:a, :b, :c], [:a, :b, :d]).should_not eql true
    end

    it "performs a comparison of wildcard scopes" do
      described_class.scopes_match?([:a, '*'], [:a, :b, :c]).should_not eql true
      described_class.scopes_match?([:a, '*', :c], [:a, :b, :c]).should eql true
      described_class.scopes_match?([:a, :b, :c], [:a, '*', :c]).should eql true
      described_class.scopes_match?([:a, :b, :c], [:a, '*', '*']).should eql true
    end
  end
end
