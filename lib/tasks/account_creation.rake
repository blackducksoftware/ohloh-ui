task new_account: :environment do
  puts 'Beginning new account creation....''
  puts
  puts "Specify the user's name......"
  name = STDIN.gets.chomp
  puts
  puts "Specify the user's login...."
  login = STDIN.gets.chomp
  puts
  puts "Specify the user's email...."
  email = STDIN.gets.chomp

  password = "#{login}_#{email}"[0..40]
  account = Account.new(login: login, name: name,
                        email: email, email_confirmation: email,
                        password: password, password_confirmation: password)

  if account.valid?
    puts 'New account is valid. Sending confirmation email now....'
    account.save!
  else
    puts "New account error #{account.errors.full_messages}"
  end

  puts "Name is #{name}"
  puts
  puts "Login is #{login}"
  puts
  puts "Email is #{email}"
  puts
  puts "Password is #{password}"
end
