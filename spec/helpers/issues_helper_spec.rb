RAILS_ROOT = File.expand_path('../../..', __FILE__)
$LOAD_PATH.unshift("#{RAILS_ROOT}/app/helpers")

require 'issues_helper'

describe IssuesHelper do
  include IssuesHelper

  # date_formalization
  describe 'date_formalization' do
    it "'2014-12-12' を渡すと'2014/12/12'が返ってくること" do
      expect(date_formalization('2014-12-12')).to eq('2014/12/12')
    end
    it "'0014-07-09' を渡すと'0014/07/09'が返ってくること" do
      expect(date_formalization('0014-07-09')).to eq('0014/07/09')
    end
    it "'0000-00-00' を渡すと'0000/00/00'が返ってくること" do
      expect(date_formalization('0000-00-00')).to eq('0000/00/00')
    end
  end

  # add_csv
  describe 'add_csv_oneline' do
    it %q(a: 'aa', b: 'bb' を渡すと aa,bb\r\n が返ってくること) do
      expect(add_csv_oneline('', a: 'aa', b: 'bb')).to eq(%("aa","bb"\r\n))
    end
  end
  describe 'add_csv_oneline' do
    it %q(a: '' を渡すと ""\r\n が返ってくること) do
      expect(add_csv_oneline('', a: '')).to eq(%(""\r\n))
    end
  end
  describe 'add_csv_oneline' do
    it %q(a: '"'  を渡すと """"\r\n が返ってくること) do
      expect(add_csv_oneline('', a: '"')).to eq(%(""""\r\n))
    end
  end
  describe 'add_csv_oneline' do
    it %q(a: 'a"b""c', b: '"d"' を渡すと "a""b""""c","""d"""\r\n が返ってくること) do
      expect(add_csv_oneline('', a: 'a"b""c', b: '"d"')).to eq(%("a""b""""c","""d"""\r\n))
    end
  end

end
