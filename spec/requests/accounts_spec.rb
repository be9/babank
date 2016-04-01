require 'rails_helper'

RSpec.describe 'API 1 accounts', type: :request do
  let(:customer) { create(:customer) }

  shared_examples_for "non-existing customer" do
    it 'returns 404 with no token given', authorize: true do
      do_default
      expect(response).to be_not_found
    end
  end

  context 'GET /customers/:customer_id/accounts' do
    context 'when authorized', authorize: true do
      it 'returns accounts with names', :show_in_doc do
        account = create(:account, customer: customer)

        do_get customer.id

        expect(response).to be_success
        b = json_body

        expect(b).to be_kind_of(Array)
        expect(b.last.slice(:id, :name)).to eq(account.attributes.slice(:id, :name))
      end
    end

    it_should_behave_like "unauthorized"
    it_should_behave_like "non-existing customer"

    private

    def do_get(customer_id, opts: {})
      super "/api/1/customers/#{customer_id}/accounts", opts
    end

    def do_default; do_get(0) end
  end

  ##########################################################

  context 'POST /customers/:customer_id/accounts' do
    context 'when authorized', authorize: true do
      it 'creates a account', :show_in_doc do

        do_post customer.id, account: { name: 'Checking', deposit: '1.23' }

        expect(response).to be_success

        b = json_body
        expect(b).to be_kind_of(Hash)
        expect(b["id"]).to be
        expect(b["name"]).to eq('Checking')
        expect(b["closed_on"]).to be_nil
        expect(b["deposit"]).to eq("1.23")
      end

      it 'requires account info' do
        do_post customer.id

        expect(response.status).to eq(422)
        expect(json_body).to eq({'message' => 'Missing parameter account'})
      end

      it 'requires account name to be non-blank' do
        do_post customer.id, account: { name: '' }

        expect(response.status).to eq(422)
        expect(json_body).to eq({'message' => 'Validation failed', 'errors' => ["Name can't be blank"]})
      end

      it 'requires account deposit to be a positive number' do
        do_post customer.id, account: { name: 'Checking', deposit: '-0.01' }

        expect(response.status).to eq(422)
        expect(json_body).to eq({'message' => 'Validation failed', 'errors' => ["Deposit must be greater than or equal to 0"]})
      end
    end

    it_should_behave_like "unauthorized"
    it_should_behave_like "non-existing customer"

    private

    def do_post(customer_id, opts = {})
      super "/api/1/customers/#{customer_id}/accounts", opts
    end

    def do_default; do_post(0) end
  end

  ##########################################################

  context 'PUT /accounts/:id' do
    let(:account) { create(:account, customer: customer) }

    context 'when authorized', authorize: true do
      it 'updates a account', :show_in_doc do
        do_put account.id, account: { name: 'Laundry', closed_on: '2016-04-01' }

        expect(response).to be_success

        b = json_body
        expect(b).to be_kind_of(Hash)
        expect(b["id"]).to eq(account.id)
        expect(b["name"]).to eq('Laundry')
        expect(b["closed_on"]).to eq('2016-04-01')

        expect(account.reload.name).to eq('Laundry')
      end

      it 'responds with 404 if account not found', :show_in_doc do
        do_put 'n0tf0und', account: { name: 'John Doe' }

        expect(response).to be_not_found
      end

      it 'requires account info' do
        do_put account.id

        expect(response.status).to eq(422)
        expect(json_body).to eq({'message' => 'Missing parameter account'})
      end

      it 'requires account name to be non-blank', :show_in_doc do
        do_put account.id, account: { name: '' }

        expect(response.status).to eq(422)
        expect(json_body).to eq({'message' => 'Validation failed', 'errors' => ["Name can't be blank"]})
      end

      it 'requires account deposit to be a positive number' do
        do_put account.id, account: { name: 'Checking', deposit: '-0.01' }

        expect(response.status).to eq(422)
        expect(json_body).to eq({'message' => 'Validation failed', 'errors' => ["Deposit must be greater than or equal to 0"]})
      end
    end

    it_should_behave_like "unauthorized"
    it_should_behave_like "non-existing customer"

    private

    def do_put(id, opts = {})
      super "/api/1/accounts/#{id}", opts
    end

    def do_default; do_put(0, account: { foo: 'bar' }) end
  end
end
