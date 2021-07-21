require 'rails_helper'

RSpec.describe Events::Event do
  it 'can append request details' do
    event = Events::Event.new
    output = event.with_request_details(fake_request).as_json

    expect(output).to match a_hash_including({
      'request_uuid' => '123',
      'request_user_agent' => 'SomeClient',
      'request_method' => 'GET',
      'request_path' => '/',
      'request_query' => [],
      'request_referer' => nil,
    })
  end

  describe 'anonymised_user_agent_and_ip' do
    subject(:field) do
      request = fake_request(
        remote_ip: remote_ip,
        user_agent: user_agent,
      )

      event = Events::Event.new
      event.with_request_details(request).as_json['anonymised_user_agent_and_ip']
    end

    context 'user agent and IP are both present' do
      let(:user_agent) { 'SomeClient' }
      let(:remote_ip) { '1.2.3.4' }

      it { is_expected.to eq '90d5c396fe8da875d25688dfec3f2881c52e81507614ba1958262c8443db29c5' }
    end

    context 'user agent is present but IP is not' do
      let(:user_agent) { 'SomeClient' }
      let(:remote_ip) { nil }

      it { is_expected.to be_nil }
    end

    context 'IP is present but user agent is not' do
      let(:user_agent) { nil }
      let(:remote_ip) { '1.2.3.4' }

      it { is_expected.to eq '6694f83c9f476da31f5df6bcc520034e7e57d421d247b9d34f49edbfc84a764c' }
    end

    context 'neither IP not user agent is present' do
      let(:user_agent) { nil }
      let(:remote_ip) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe 'data pairs' do
    it 'converts booleans to strings' do
      event = Events::Event.new
      output = event.with_data(key: true).as_json
      expect(output['data'].first['value']).to eq ['true']
    end
  end

  def fake_request(overrides = {})
    attrs = {
      uuid: '123',
      method: 'GET',
      path: '/',
      query_string: '',
      referer: nil,
      user_agent: 'SomeClient',
      remote_ip: '1.2.3.4',
    }.merge(overrides)

    instance_double(ActionDispatch::Request, attrs)
  end
end
