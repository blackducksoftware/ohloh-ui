Rails.application.middleware.use(Oink::Middleware, instruments: :memory)
