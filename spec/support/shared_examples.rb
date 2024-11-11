RSpec.shared_examples 'basic data retrieval tests' do
  context 'with successful API response' do
    before do
      allow(access_token).to receive(:get)
        .with('https://api.mlh.com/v4/users/me')
        .and_return(double(parsed: { 'data' => base_user_data }))
    end

    it 'returns symbolized user data' do
      expect(subject.data).to include(
        id: 'c2ac35c6-aa8c-11ed-afa1-0242ac120002',
        first_name: 'Jane'
      )
    end
  end
end

RSpec.shared_examples 'expandable fields tests' do
  let(:expanded_user_data) do
    base_user_data.merge({
      'profile' => {
        'age' => 22,
        'gender' => 'Female'
      },
      'education' => [{
        'current' => true,
        'school_name' => 'Hacker University',
        'major' => 'Computer Science'
      }]
    })
  end

  context 'with expandable fields' do
    before do
      allow(access_token).to receive(:get)
        .with('https://api.mlh.com/v4/users/me?expand[]=profile&expand[]=education')
        .and_return(double(parsed: { 'data' => expanded_user_data }))
    end

    it 'fetches expanded fields' do
      allow(subject).to receive(:options).and_return(expand_fields: ['profile', 'education'])
      expect(subject.data).to include(
        profile: include(age: 22),
        education: include(hash_including(school_name: 'Hacker University'))
      )
    end
  end
end

RSpec.shared_examples 'error handling tests' do
  context 'when API returns error' do
    before do
      allow(access_token).to receive(:get).and_raise(StandardError)
    end

    it 'returns empty hash on error' do
      expect(subject.data).to eq({})
    end
  end
end

RSpec.shared_examples 'info hash tests' do
  let(:user_info) do
    {
      id: 'c2ac35c6-aa8c-11ed-afa1-0242ac120002',
      first_name: 'Jane',
      last_name: 'Hacker',
      email: 'jane.hacker@example.com'
    }
  end

  before do
    allow(subject).to receive(:data).and_return(user_info)
  end

  it 'returns formatted info hash' do
    expect(subject.info).to include(
      name: 'Jane Hacker',
      email: 'jane.hacker@example.com'
    )
  end
end
