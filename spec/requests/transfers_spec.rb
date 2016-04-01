require 'rails_helper'

RSpec.describe 'API 1 transfers', type: :request do
  let(:acc1) { create(:account) }
  let(:acc2) { create(:account) }

  xcontext 'GET /transfers' do
    context 'when authorized', authorize: true do
      it 'is success' do
        do_get

        expect(response).to be_success
      end

      it 'returns transfers with names', :show_in_doc do
        transfer = create(:transfer)

        do_get

        expect(response).to be_success
        b = json_body

        expect(b).to be_kind_of(Array)
        expect(b.last.slice(:id, :name)).to eq(transfer.attributes.slice(:id, :name))
      end
    end

    it_should_behave_like "unauthorized" do
      def do_default; do_get end
    end

    private

    def do_get(opts: {})
      super '/api/1/transfers', opts
    end
  end

  ##########################################################

  context 'POST /transfers' do

    context 'when authorized', authorize: true do
      it 'creates a transfer', :show_in_doc do

        do_post transfer: { source_id: acc1.id, target_id: acc2.id, amount: 50, date: Date.new(2016, 4, 1) }

        expect(response).to be_success

        b = json_body
        expect(b).to be_kind_of(Hash)
        expect(b["id"]).to be
        expect(b["amount"]).to eq('50.0')
      end

      it 'requires transfer info' do
        do_post

        expect(response.status).to eq(422)
        expect(json_body).to eq({'message' => 'Missing parameter transfer'})
      end

      it 'requires amount to be a positive number' do
        do_post transfer: { source_id: acc1.id, target_id: acc2.id, amount: 0.0, date: Date.new(2016, 4, 1) }
        expect(response.status).to eq(422)
        expect(json_body).to eq({'message' => 'Validation failed', 'errors' => ["Amount must be greater than 0"]})

        do_post transfer: { source_id: acc1.id, target_id: acc2.id, amount: -0.01, date: Date.new(2016, 4, 1) }
        expect(response.status).to eq(422)
        expect(json_body).to eq({'message' => 'Validation failed', 'errors' => ["Amount must be greater than 0"]})
      end

      it 'returns 404 if source account is not present' do
        do_post transfer: { source_id: 0, target_id: acc2.id, amount: 0.05, date: Date.new(2016, 4, 1) }
        expect(response.status).to eq(404)
      end

      it 'returns 404 if source account is not present' do
        do_post transfer: { target_id: 0, source_id: acc1.id, amount: 0.05, date: Date.new(2016, 4, 1) }
        expect(response.status).to eq(404)
      end
    end

    it_should_behave_like "unauthorized" do
      def do_default; do_post end
    end

    private

    def do_post(opts = {})
      super '/api/1/transfers', opts
    end
  end

  ##########################################################

  context 'PUT /transfers/:id' do
    let(:transfer) { create(:transfer) }

    context 'when authorized', authorize: true do
      it 'updates a transfer', :show_in_doc do
        do_put transfer.id, transfer: { amount: '0.99', retracted_on: Date.new(2014, 4, 1) }

        expect(response).to be_success

        b = json_body
        expect(b).to be_kind_of(Hash)
        expect(b["id"]).to eq(transfer.id)
        expect(b["amount"]).to eq('0.99')

        expect(transfer.reload.retracted_on).to eq(Date.new(2014, 4, 1))
      end

      it 'responds with 404 if transfer not found', :show_in_doc do
        do_put 'n0tf0und', transfer: { amount: '0.99' }

        expect(response).to be_not_found
      end

      it 'requires transfer info' do
        do_put transfer.id

        expect(response.status).to eq(422)
        expect(json_body).to eq({'message' => 'Missing parameter transfer'})
      end

      it 'requires amount to be a positive number' do
        do_put transfer.id, transfer: { source_id: acc1.id, target_id: acc2.id, amount: 0.0, date: Date.new(2016, 4, 1) }
        expect(response.status).to eq(422)
        expect(json_body).to eq({'message' => 'Validation failed', 'errors' => ["Amount must be greater than 0"]})

        do_put transfer.id, transfer: { source_id: acc1.id, target_id: acc2.id, amount: -0.01, date: Date.new(2016, 4, 1) }
        expect(response.status).to eq(422)
        expect(json_body).to eq({'message' => 'Validation failed', 'errors' => ["Amount must be greater than 0"]})
      end

      it 'returns 404 if source account is not present' do
        do_put transfer.id, transfer: { source_id: 0, target_id: acc2.id, amount: 0.05, date: Date.new(2016, 4, 1) }
        expect(response.status).to eq(404)
      end

      it 'returns 404 if source account is not present' do
        do_put transfer.id, transfer: { target_id: 0, source_id: acc1.id, amount: 0.05, date: Date.new(2016, 4, 1) }
        expect(response.status).to eq(404)
      end

    end

    it_should_behave_like "unauthorized" do
      def do_default; do_put(transfer.id) end
    end

    private

    def do_put(id, opts = {})
      super "/api/1/transfers/#{id}", opts
    end
  end
end
