class AccountsController < ApplicationController
  before_action :find_customer, only: %i(index create)

  resource_description do
    short 'Customer Accounts'
    formats %w(json)
    api_version "1"
  end

  def_param_group :account do
    param :account, Hash, desc: 'Account info', required: true do
      param :name, String, desc: 'Account name'
      param :deposit, String, desc: 'Account initial deposit'
      param :closed_on, /^\d{4}-\d{2}-\d{2}$/, desc: 'Account closing date'
    end
  end

  api :GET, '/1/customers/:customer_id/accounts', 'List accounts for a given customer'
  api_version '1'
  description 'Get a full list of accounts'
  param :customer_id, String, required: true, desc: 'Customer ID'
  error code: 404, desc: 'Customer not found'
  def index
    accounts = @customer.accounts.all

    render json: accounts
  end

  ##########################################################

  api :POST, '/1/customers/:customer_id/accounts', 'Create an account'
  api_version '1'
  description 'Create a new account for a given customer'
  param_group :account
  param :customer_id, String, required: true, desc: 'Customer ID'
  error code: 422, desc: 'Invalid attributes'
  error code: 404, desc: 'Customer not found'
  def create
    account = @customer.accounts.build(account_params)

    if account.save
      render status: :created, json: account
    else
      render status: :unprocessable_entity, json: { errors: account.errors.full_messages, message: 'Validation failed' }
    end
  end

  api :PUT, '/1/accounts/:id', 'Update an account'
  api_version '1'
  description 'Updates account information'
  param_group :account
  param :id, String, required: true, desc: 'Account ID'
  error code: 422, desc: 'Invalid attributes'
  error code: 404, desc: 'Account not found'
  def update
    account = Account.find params[:id]

    if account.update(account_params)
      render json: account
    else
      render status: :unprocessable_entity, json: { errors: account.errors.full_messages, message: 'Validation failed' }
    end
  end

  private

  def find_customer
    @customer = Customer.find params[:customer_id]
  end

  def account_params
    params.require(:account).permit(:name, :deposit, :closed_on)
  end
end
