# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/securities/oanda_securities'
require 'jiji/model/securities/internal/examples/ordering_examples'
require 'jiji/model/securities/internal' \
        + '/examples/ordering_response_pattern_examples'

describe Jiji::Model::Securities::Internal::Oanda::Ordering do
  let(:wait) { 1 }
  let(:client) do
    Jiji::Model::Securities::OandaDemoSecurities.new(
      access_token: ENV['OANDA_API_ACCESS_TOKEN'])
  end
  let(:backtest_id) { nil }

  it_behaves_like '注文関連の操作'
  it_behaves_like '注文関連の操作(建玉がある場合のバリエーションパターン)'
end