require 'rails_helper'

RSpec.describe 'API 1 transfers', type: :request do
  let(:acc1) { create(:account, deposit: 0) }
  let(:acc2) { create(:account) }

  context 'GET /transfers', focus:true do
    context 'when authorized', authorize: true do
      let(:transfer) { create(:transfer, source: acc1, target: acc2, amount: "1") }

      it 'returns transfers', :show_in_doc do
        do_get transfer.source_id, start_date: transfer.date, end_date: transfer.date

        expect(response).to be_success
        b = json_body

        expect(b).to be_kind_of(Hash)
        expect(b["balance"]["starting"]).to eq("0.0")
        expect(b["balance"]["ending"]).to eq("-1.0")

        expect(b["transfers"].last["id"]).to eq(transfer.id)
      end

      it 'does not show transfers made earlier than start_date' do
        do_get transfer.source_id, start_date: transfer.date + 1, end_date: transfer.date + 1

        expect(response).to be_success
        b = json_body

        expect(b).to be_kind_of(Hash)
        expect(b["balance"]["starting"]).to eq("-1.0")
        expect(b["balance"]["ending"]).to eq("-1.0")
        expect(b["transfers"]).to be_empty
      end

      it 'does not show transfers made later than end_date' do
        do_get transfer.source_id, start_date: transfer.date - 1, end_date: transfer.date - 1

        expect(response).to be_success
        b = json_body

        expect(b).to be_kind_of(Hash)
        expect(b["balance"]["starting"]).to eq("0.0")
        expect(b["balance"]["ending"]).to eq("0.0")
        expect(b["transfers"]).to be_empty
      end

      it 'shows retracted transfers too' do
        transfer.retracted_on = Date.today
        transfer.save!

        do_get transfer.source_id, start_date: transfer.date, end_date: transfer.date

        expect(response).to be_success
        b = json_body

        expect(b).to be_kind_of(Hash)
        expect(b["balance"]["starting"]).to eq("0.0")
        expect(b["balance"]["ending"]).to eq("0.0")

        expect(b["transfers"].last["id"]).to eq(transfer.id)
      end

      it 'respects pagination and sets Link header' do
        date = Date.new(2016, 4, 1)
        transfers = create_list(:transfer, 10, source: acc1, target: acc2, amount: "1", date: date)

        do_get acc2.id, start_date: transfer.date, end_date: transfer.date, page: 3, per_page: 3

        expect(response).to be_success
        b = json_body

        expect(b["transfers"].size).to eq(3)

        link = response.headers['Link'].split(',').map(&:strip)
        expect(link.size).to eq 4

        links = {}
        link.each do |l|
          l =~ /<([^>]*)>; rel="([^"]*)"/

          links[$2.to_sym] = $1
        end

        uri = -> page { URI.parse("http://www.example.com/api/1/accounts/#{acc2.id}/transfers?end_date=2016-04-01&page=#{page}&per_page=3&start_date=2016-04-01") }

        expect(URI.parse(links[:first])).to eq(uri.(1))
        expect(URI.parse(links[:prev])).to eq(uri.(2))
        expect(URI.parse(links[:next])).to eq(uri.(4))
        expect(URI.parse(links[:last])).to eq(uri.(4))
      end
    end

    it_should_behave_like "unauthorized" do
      def do_default; do_get 0, start_date: Date.today, end_date: Date.today end
    end

    private

    def do_get(account_id, opts = {})
      super "/api/1/accounts/#{account_id}/transfers", opts
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
