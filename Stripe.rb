require "json"

get "/customer" do
  begin
    customer_id = "..."
    customer = Stripe::Customer.retrieve(customer_id)
  rescue Stripe::StripeError => e
    status 402
    return "Error returning customer: #{e.message}"
  end
  status 200
  content_type: json
  customer.to_j
end

post "/customer/sources" do
  begin
    customer_id = "..." # Load the Stripe Customer ID for your logged in user
    customer = Stripe::Customer.retrieve(customer_id)
    customer.sources.create({:source => params[:source]})
    status 200
  rescue Stripe::StripeError => e
    status 402
    return "Error retrieving customer: #{e.message}"
  end
end

post "/customer/default_source" do
  begin
    customer_id = "..." # Load the Stripe Customer ID for your logged in user
    customer = Stripe::Customer.retrieve(customer_id)
    customer.default_source = params[:default_source]
    customer.save
    status 200
  rescue Stripe::StripeError => e
    status 402
    return "Error retrieving customer: #{e.message}"
  end
end

Stripe.api_key = "sk_test_PbH5UZ20DwkBVbf6qWeOHSfh"
token = params[:stripeToken]
begin
  charge = Stripe::Charge.create(
    :amount => 1000,
    :currency => "usd",
    :source => token,
    :description => "Shoveled charge",
    :metadata => {"postId" : "12345"}
  )
rescue Stripe::CardError => e

end
