require 'rails_helper'

RSpec.describe 'API 1 customers', type: :request do

  context 'GET /customers' do
    context 'when authorized', authorize: true do
      it 'is success' do
        do_get

        expect(response).to be_success
      end

      it 'returns customers with names' do
        customer = create(:customer)

        do_get

        expect(response).to be_success
        b = json_body

        expect(b).to be_kind_of(Array)
        expect(b.last.slice(:id, :name)).to eq(customer.attributes.slice(:id, :name))
      end
    end

    it_should_behave_like "unauthorized" do
      def do_it; do_get end
    end

    private

    def do_get(opts: {})
      super '/api/1/customers', opts
    end
  end

  ##########################################################

  context 'POST /customers' do
    context 'when authorized', authorize: true do
      it 'creates a customer' do
        do_post customer: { name: 'John Doe' }

        expect(response).to be_success

        b = json_body
        expect(b).to be_kind_of(Hash)
        expect(b["id"]).to be
        expect(b["name"]).to eq('John Doe')
      end

      it 'requires customer info' do
        do_post

        expect(response.status).to eq(422)
        expect(json_body).to eq({'message' => 'Missing parameter customer'})
      end

      it 'requires customer name' do
        do_post customer: { foo: 'bar' }

        expect(response.status).to eq(422)
        expect(json_body).to eq({'message' => 'Missing parameter name'})
      end

      it 'requires customer name to be non-blank' do
        do_post customer: { name: '' }

        expect(response.status).to eq(422)
        expect(json_body).to eq({'message' => 'Validation failed', 'errors' => ["Name can't be blank"]})
      end
    end

    it_should_behave_like "unauthorized" do
      def do_it; do_post end
    end

    private

    def do_post(opts = {})
      super '/api/1/customers', opts
    end
  end

  ##########################################################

  context 'PUT /customers/:id' do
    let(:customer) { create(:customer) }

    context 'when authorized', authorize: true do
      it 'updates a customer' do
        do_put customer.id, customer: { name: 'John Doe' }

        expect(response).to be_success

        b = json_body
        expect(b).to be_kind_of(Hash)
        expect(b["id"]).to eq(customer.id)
        expect(b["name"]).to eq('John Doe')

        expect(customer.reload.name).to eq('John Doe')
      end

      it 'responds with 404 if customer not found' do
        do_put 'n0tf0und', customer: { name: 'John Doe' }

        expect(response).to be_not_found
      end

      it 'requires customer info' do
        do_put customer.id

        expect(response.status).to eq(422)
        expect(json_body).to eq({'message' => 'Missing parameter customer'})
      end

      it 'requires customer name' do
        do_put customer.id, customer: { foo: 'bar' }

        expect(response.status).to eq(422)
        expect(json_body).to eq({'message' => 'Missing parameter name'})
      end

      it 'requires customer name to be non-blank' do
        do_put customer.id, customer: { name: '' }

        expect(response.status).to eq(422)
        expect(json_body).to eq({'message' => 'Validation failed', 'errors' => ["Name can't be blank"]})
      end
    end

    it_should_behave_like "unauthorized" do
      def do_it; do_put(customer.id) end
    end

    private

    def do_put(id, opts = {})
      super "/api/1/customers/#{id}", opts
    end
  end
end
