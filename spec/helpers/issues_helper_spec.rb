RAILS_ROOT = File.expand_path('../../..', __FILE__)
$LOAD_PATH.unshift("#{RAILS_ROOT}/app/helpers")

require 'issues_helper'

describe IssuesHelper do
  include IssuesHelper

  describe 'add_csv_oneline' do
    it "a: 'aa', b: 'bb' を渡すと a,bCRLF が返ってくること" do
      expect(add_csv_oneline('', a: 'aa', b: 'bb')).to eq(%("aa","bb"CRLF))
    end
  end
  describe 'add_csv_oneline' do
    it %q(a: '' を渡すと ""CRLF が返ってくること) do
      expect(add_csv_oneline('', a: '')).to eq(%(""CRLF))
    end
  end
  describe 'add_csv_oneline' do
    it %q(a: '"'  を渡すと """"CRLF が返ってくること) do
      expect(add_csv_oneline('', a: '"')).to eq(%(""""CRLF))
    end
  end
  describe 'add_csv_oneline' do
    it %q(a: 'a"b""c', b: '"d"' を渡すと "a""b""""c","""d"""CRLF が返ってくること) do
      expect(add_csv_oneline('',  a: 'a"b""c', b: '"d"')).to eq(%("a""b""""c","""d"""CRLF))
    end
  end
end