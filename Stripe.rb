Stripe.api_key = "sk_test_PbH5UZ20DwkBVbf6qWeOHSfh"
token = params[:stripeToken]
begin
  charge = Stripe::Charge.create(
    :amount => 1000,
    :currency => "usd",
    :source => token,
    :description => "Example charge"
  )
rescue Stripe::CardError => e

end
