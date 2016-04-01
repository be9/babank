RSpec.shared_examples_for "unauthorized" do
  it 'returns 403 with no token given' do
    do_default
    expect(response).to be_forbidden
  end

  it 'returns 403 with bad token given', authorize: :bad do
    do_default
    expect(response).to be_forbidden
  end
end
