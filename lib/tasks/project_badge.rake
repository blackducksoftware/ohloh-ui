namespace :project_badge do
  namespace :cii do
    desc 'Check CII best practices projects'
    task check_projects: :environment do
      puts '-------------- CII projects check started ----------'
      puts "Start Time: #{Time.current}"
      CiiProject = Struct.new(:id, :name, :homepage_url, :repo_url)
      cii_projects = []
      page = 1
      loop do
        projects = JSON.parse Net::HTTP.get(URI("#{ENV['CII_API_BASE_URL']}projects.json?page=#{page}"))
        break if projects.blank?
        projects.each do |p|
          next if CiiBadge.find_by identifier: p['id']
          cii_projects << CiiProject.new(*p.slice('id', 'name', 'homepage_url', 'repo_url').values)
        end
        page += 1
      end
      ProjectBadgeMailer.check_cii_projects(cii_projects).deliver_now if cii_projects.present?
      Setting.find_or_initialize_by(key: 'check_cii_projects').update(value: Time.current)
      puts "End Time: #{Time.current}"
      puts "New CII projects found: #{cii_projects.size}"
      puts "-------------- CII projects check finished ----------\n"
    end
  end
end
