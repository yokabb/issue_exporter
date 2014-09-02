RAILS_ROOT = File.expand_path('../../..', __FILE__)
$LOAD_PATH.unshift("#{RAILS_ROOT}/app/helpers")

require 'issues_helper.rb'

describe IssuesHelper do
  include IssuesHelper

  # make_labels_in_header
  describe 'make_labels_in_header' do
    it '%w(a b), %w(c d), %w(d b) を渡すと %w(d b a c) が返ってくること' do
      x, y, z = %w(a b), %w(c d), %w(d b)
      res = %w(d b a c)
      expect(make_labels_in_header(x, y, z)).to eq(res)
    end
    it '%w(a b), [], %w(b) を渡すと %w(b a) が返ってくること' do
      x, y, z = %w(a b), [], %w(b)
      res = %w(b a)
      expect(make_labels_in_header(x, y, z)).to eq(res)
    end
    it '%w(a), %w(c), %w(-) を渡すと %w(a c) が返ってくること' do
      x, y, z = %w(a), %w(c), %w()
      res = %w(a c)
      expect(make_labels_in_header(x, y, z)).to eq(res)
    end
    it '%w(a b), %w(c d), %w(d c c) を渡すと %w(d c a b) が返ってくること' do
      x, y, z = %w(a b), %w(c d), %w(d c c)
      res = %w(d c a b)
      expect(make_labels_in_header(x, y, z)).to eq(res)
    end
  end

  # pull_request?
  describe 'pull_request?' do
    it "{ number: '1' }, {} を渡すと'false'が返ってくること" do
      expect(pull_request?({ user: 'a', number: '1' }, {})).to eq(false)
    end
    it "{ number: '1' }, [{ user: 'a', number: '1' }, {}] を渡すと'true'が返ってくること" do
      expect(pull_request?({ number: '1' }, [{ user: 'a', number: '1' }, {}])).to eq(true)
    end
    it "{ number: '1' }, [{ user: 'a', number: '2' }, {}] を渡すと'false'が返ってくること" do
      expect(pull_request?({ number: '1' }, [{ user: 'a', number: '2' }, {}])).to eq(false)
    end
  end

  # in_date_range?
  describe 'in_date_range?' do
    it "'2014-01-01T12:34:56Z', '2014-01-01', '2014-02-01' 渡すと'true'が返ってくること" do
      expect(in_date_range?('2014-01-01T12:34:56Z', '2014-01-01', '2014-02-01')).to eq(true)
    end
    it "'2013-12-31T14:59:59Z', '2014/01/01', '2014/02/01' 渡すと'false'が返ってくること" do
      expect(in_date_range?('2013-12-31T14:59:59Z', '2014-01-01', '2014-02-01')).to eq(false)
    end
    it "'2013-12-31T15:00:00Z', '2014/01/01', '2014/02/01' 渡すと'true'が返ってくること" do
      expect(in_date_range?('2013-12-31T15:00:00Z', '2014-01-01', '2014-02-01')).to eq(true)
    end
    it "'2014-02-01T14:59:59Z', '2014/01/01', '2014/02/01' 渡すと'true'が返ってくること" do
      expect(in_date_range?('2014-02-01T14:59:59Z', '2014-01-01', '2014-02-01')).to eq(true)
    end
    it "'2014-02-01T15:00:00Z', '2014/01/01', '2014/02/01' 渡すと'false'が返ってくること" do
      expect(in_date_range?('2014-02-01T15:00:00Z', '2014-01-01', '2014-02-01')).to eq(false)
    end
  end

  # date_formalization
  describe 'date_formalization' do
    it "'2014-07-09T12:34:56Z' を渡すと'2014/07/09'が返ってくること" do
      expect(date_formalization('2014-07-09T12:34:56Z')).to eq('2014/07/09')
    end
    it "'0000-01-01T14:59:59Z' を渡すと'0001/01/01'が返ってくること" do
      expect(date_formalization('0000-01-01T14:59:59Z')).to eq('0000/01/01')
    end
    it "'0000-01-01T15:00:00Z' を渡すと'0000/01/02'が返ってくること" do
      expect(date_formalization('0000-01-01T15:00:00Z')).to eq('0000/01/02')
    end
    it "'0999-12-31T15:00:00Z' を渡すと'1000/01/01'が返ってくること" do
      expect(date_formalization('0999-12-31T15:00:00Z')).to eq('1000/01/01')
    end
  end

end
