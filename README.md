### Babank

Babank is an implementation of a "Bank" API specified in [this document](https://github.com/be9/babank/blob/master/build_a_bank.md).
Pronounce it as "baBANG".

### Installation and Usage

It's a Rails app and can be easily deployed to e.g. Heroku. Here's my [deployed version](https://babank-for-plaid.herokuapp.com/).

The app provides a bunch of API endpoints (`/api/1/...`) and a [documentation page](https://babank-for-plaid.herokuapp.com/apipie) which details their usage.

Endpoints can be tested with curl, but you'll have to provide a valid auth token,
otherwise you'll get a 403 error.

    curl -H 'Authorization: token SuperSecret' https://babank-for-plaid.herokuapp.com/api/1/customers

### Architecture Considerations

#### No Deletion

Banks don't delete anything. You can't delete anything in babank, but you can *close* accounts (a transfer cannot be created if any of accounts it's related to has been closed before). Also transfers can be *retracted*. They won't disappear, but retracted transfers don't count against balance.

#### Balance Calculation

Balance is calculated "live" with a special SQL query, so there's a [separate endpoint](https://babank-for-plaid.herokuapp.com/apipie/1/accounts/show.html) to find it out.

#### Negative Balances

Babank doesn't check if account has enough balance to make a transfer. This is intentional, because banks technically allow negative balances even on debit cards. However, initial account deposit value must be non-negative. 

#### Transfer History

[Get transfers for a given account](https://babank-for-plaid.herokuapp.com/apipie/1/transfers/index.html) is probably the trickiest endpoint because it makes sure you won't request too many data at once. You must provide a date interval (start_date .. end_date) and then it enforces pagination on you. No more than one page (max. size 100) will be returned.

### Things that I would do next..

Now, this is a limited scope project, but here are things I would certainly add if I had more time:

* More accurate authentication with separate users (currently it's only a single token) and different levels of access.
* Audit log. Store all operations, esp. updates and retraction into a separate table.
* Caching. Database load could be mitigated if balances were to cached.
