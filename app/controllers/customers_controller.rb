class CustomersController < ApplicationController

  resource_description do
    short 'Bank Customers'
    formats %w(json)
    api_version "1"
  end

  def_param_group :customer do
    param :customer, Hash, desc: 'Customer info', required: true do
      param :name, String, desc: 'Customer name', required: true
    end
  end

  api :GET, '/1/customers', 'List customers'
  api_version '1'
  description 'Get a full list of customers'
  def index
    customers = Customer.all

    render json: customers
  end

  ##########################################################

  api :POST, '/1/customers', 'Create a customer'
  api_version '1'
  description 'Create a new customer with a given name'
  param_group :customer
  error code: 422, desc: 'Invalid attributes'
  def create
    customer = Customer.new(customer_params)

    if customer.save
      render status: :created, json: customer
    else
      render status: :unprocessable_entity, json: { errors: customer.errors.full_messages, message: 'Validation failed' }
    end
  end

  ##########################################################

  api :PUT, '/1/customers/:id', 'Update a customer record'
  api_version '1'
  description 'Updates customer information'
  param_group :customer
  param :id, String, required: true, desc: 'Customer ID'
  error code: 422, desc: 'Invalid attributes'
  error code: 404, desc: 'Not found'
  def update
    customer = Customer.find params[:id]

    if customer.update(customer_params)
      render json: customer
    else
      render status: :unprocessable_entity, json: { errors: customer.errors.full_messages, message: 'Validation failed' }
    end
  end

  private

  def customer_params
    params.require(:customer).permit(:name)
  end
end
