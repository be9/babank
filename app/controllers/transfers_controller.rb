class TransfersController < ApplicationController
  resource_description do
    short 'Transfers between accounts'
    formats %w(json)
    api_version "1"
  end

  date_regex = /^\d{4}-\d{2}-\d{2}$/

  def_param_group :transfer do
    param :transfer, Hash, desc: 'Transfer info', required: true do
      param :source_id, String, desc: 'Source account ID'
      param :target_id, String, desc: 'Target account ID'
      param :amount, String, desc: 'Transfer amount'
      param :date, date_regex, desc: 'Operation date'
      param :retracted_on, date_regex, desc: 'Retraction date'
    end
  end

  ##########################################################

  api :POST, '/1/transfers', 'Create a transfer'
  api_version '1'
  description 'Create a new transfer'
  param_group :transfer
  error code: 422, desc: 'Invalid attributes'
  def create
    transfer = Transfer.new(transfer_params)

    load_accounts(transfer)

    if transfer.save
      render status: :created, json: transfer
    else
      render status: :unprocessable_entity, json: { errors: transfer.errors.full_messages, message: 'Validation failed' }
    end
  end

  ##########################################################

  api :PUT, '/1/transfers/:id', 'Update a transfer record'
  api_version '1'
  description 'Updates transfer information'
  param_group :transfer
  param :id, String, required: true, desc: 'Transfer ID'
  error code: 422, desc: 'Invalid attributes'
  error code: 404, desc: 'Not found'
  def update
    transfer = Transfer.find params[:id]
    transfer.attributes = transfer_params
    load_accounts(transfer)

    if transfer.save
      render json: transfer
    else
      render status: :unprocessable_entity, json: { errors: transfer.errors.full_messages, message: 'Validation failed' }
    end
  end

  ##########################################################

  api :GET, '/1/accounts/:account_id/transfers', 'Get transfer history'
  api_version '1'
  description 'Retrieves transfer history for a given account'

  param :account_id, String, required: true, desc: 'Account ID'
  param :start_date, date_regex, required: true, desc: 'Start date'
  param :end_date, date_regex, required: true, desc: 'End date'
  param :per_page, String, desc: 'Records per page (default: 50, max: 100)'
  param :page, String, desc: 'Page number'

  error code: 404, desc: 'Account not found'
  def index
    account = Account.find params[:account_id]
    start_date = Date.parse params[:start_date]
    end_date = Date.parse params[:end_date]

    per_page = [[1, (params[:per_page] || 50).to_i].max, 100].min

    starting_balance = account.balance(start_date - 1)      # Not including start_date
    ending_balance = account.balance(end_date)

    transfers = Transfer.related(account).
      period(start_date, end_date).
      natural_order.
      page(params[:page]).per(per_page)

    paginate(transfers)

    render json: {
      transfers: transfers,
      balance: { starting: starting_balance,
                 ending: ending_balance }
    }
  end

  private

  def transfer_params
    params.require(:transfer).permit(:source_id, :target_id, :date, :amount, :retracted_on)
  end

  # Load accounts, will throw RecordNotFound if any of two doesn't exist
  def load_accounts(transfer)
    source = Account.find transfer.source_id
    target = Account.find transfer.target_id
  end
end
