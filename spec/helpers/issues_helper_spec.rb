RAILS_ROOT = File.expand_path('../../..', __FILE__)
$LOAD_PATH.unshift("#{RAILS_ROOT}/app/helpers")

require 'issues_helper'

describe IssuesHelper do
  include IssuesHelper

  # is_pull_request
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

  # date_formalization
  describe 'date_formalization' do
    it "'2014-07-09T12:34:56Z' を渡すと'2014-07-09T12:34:56Z'が返ってくること" do
      expect(date_formalization('2014-07-09')).to eq('2014/07/09')
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
