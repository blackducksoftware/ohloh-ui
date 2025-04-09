# frozen_string_literal: true

desc 'Remove duplicate Licenses and assign the original license to projects and permissions'
task remove_duplicate_licenses: :environment do
  hash_data = {
    license: {
      'GNU Affero General Public License v3.0' => ['GNU Affero General Public License', 'GNU Affero General Public License 3.0'],
      'GNU Affero General Public License v3.0 or later' => ['GNU Affero General Public License v3.0 or later (error)'],
      'GNU General Public License v2.0 w/Classpath exception' => ['GNU General Public License Version 2 with the Classpath Exception'],
      'xdoclet-2 license' => ['xdoclet-2-plugins-license'],
      'wxWindows Library License v3.1' => ['wxWindows Library License'],
      'WTFPLv1.1' => ['WTFPL Version 1.1'],
      'Open Software License 3.0' => ['Open Software License v. 3.0'],
      'Mozilla Public License 2.0' => ['Mozilla Public License 2.0 (Incompatible with Secondary Licenses)'],
      'i9 License' => ['i9_license'],
      'Boost Software License 1.0' => ['Boost Software License'],
      'Artistic License 2.0' => ['Artistic License'],
      'GNU General Public License v3.0' => ['General Public License v3.0'],
      'Apache License 2.0' => ['Apache', 'Apache-ish License', 'Apache License, Version 2.0'],
      '3-Clause BSD License' => ['New BSD License'],
      'Creative Commons Attribution Non Commercial 2.5 Generic' => ['Creative Commons Attribution Non Commercial 2.5'],
      'Creative Commons Attribution Non Commercial 4.0 International' => ['Creative Commons Attribution-NonCommercial 4.0 International'],
      'Creative Commons Attribution-NonCommercial-ShareAlike 2.0 Generic' => ['Creative Commons Attribution Non Commercial Share Alike 2.0'],
      'Creative Commons Attribution-ShareAlike 4.0 International' => ['CC Attribution-ShareAlike 4.0 International', 'Creative Commons Attributions-ShareAlike 4.0', 'Creative Commons Attribution-ShareAlike 4.0 International License'],
      'GNU Lesser General Public License v3.0 only' => ['GNU Lesser General Public License version 3.0', 'GNU Lesser General Public License Version 3', 'GNU Lesser General Public License v3.0']
    }
  }

  def remove_duplicates(original_license_name, duplicate_license_ids)
    original_license = License.find_by(name: original_license_name)
    if original_license.nil?
      puts "Original license '#{original_license_name}' not found."
      return
    end

    if duplicate_license_ids.empty?
      puts "No duplicate licenses found for '#{original_license_name}'."
      return
    end

    License.where(id: duplicate_license_ids).update_all(deleted: true)
    ProjectLicense.where(license_id: duplicate_license_ids).update_all(license_id: original_license.id)
    puts "Duplicates for '#{original_license_name}' removed and projects updated."
  end

  def process_licenses(hash_data)
    hash_data[:license].each do |original_license, duplicate_licenses|
      duplicate_license_ids = License.where(name: duplicate_licenses).pluck(:id)
      remove_duplicates(original_license, duplicate_license_ids)
    end
  end

  process_licenses(hash_data)
  puts "Duplicate licenses removed and projects updated."
end