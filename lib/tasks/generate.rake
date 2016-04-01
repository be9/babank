task :generate => :environment do
  gen_amount = -> { BigDecimal.new(1+rand(10000)) / 100 }

  nacc = (ENV['NACCOUNTS'] || 100).to_i
  ntr  = (ENV['NTRANSFERS'] || 1000000).to_i

  ActiveRecord::Base.transaction do
    customer = Customer.create!(name: "Customer #{Time.now}")

    accounts = []

    STDERR.puts ">>> Creating accounts"
    progressbar = ProgressBar.create(total: nacc)
    (1..nacc).each do |i|
      acc = Account.create!(customer: customer, name: "Account #{i}", deposit: gen_amount.call)

      accounts << acc
      progressbar.increment
    end

    STDERR.puts ">>> Creating transfers"
    progressbar = ProgressBar.create(total: ntr, format: '%E: |%B| %c/%C')
    (1..ntr).each do |i|
      src, tgt = accounts.shuffle.take(2)
      date = Date.new(2016, 1, 1) + rand(100)

      Transfer.create!(source: src, target: tgt, amount: gen_amount.call, date: date)

      progressbar.increment
    end

  end
end
