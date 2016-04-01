class TransfersController < ApplicationController
  resource_description do
    short 'Transfers'
    formats %w(json)
    api_version "1"
  end

  def_param_group :transfer do
    param :transfer, Hash, desc: 'Transfer info', required: true do
      param :source_id, String, desc: 'Source account ID'
      param :target_id, String, desc: 'Target account ID'
      param :amount, String, desc: 'Transfer amount'
      param :date, /^\d{4}-\d{2}-\d{2}$/, desc: 'Operation date'
      param :retracted_on, /^\d{4}-\d{2}-\d{2}$/, desc: 'Retraction date'
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
