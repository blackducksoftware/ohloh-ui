# frozen_string_literal: true

class AddKbIdFieldToLicense < ActiveRecord::Migration
  def change
    add_column :licenses, :kb_id, :uuid
    update_records
  end

  private

  # rubocop:disable Metrics/AbcSize
  def update_records
    insert_kb_id('ad705c59-6893-4980-bdbf-0837f1823cc4', 'mit', ['MIT', 'MIT License', 'mit2'])
    insert_kb_id('7cae335f-1193-421e-92f1-8802b4243e93', 'apache_2',
                 ['Apache-2.0', 'Apache20', 'Apache License 2.0', 'ASL 2.0'])
    insert_kb_id('3d238144-44e6-450e-b523-3defbdaed9dc', 'BSD-3-Clause',
                 ['BSD-3-Clause', 'BSD 3-clause "New" or "Revised" License'])
    insert_kb_id('14b0b50b-acd2-4fc8-ac65-3b15f9e58260', 'isc', ['ISC', 'isclicense', 'ISC License'])
    insert_kb_id('cc875133-df38-4806-9921-473e0ef01a87', 'BSD-2-Clause', ['BSD-2-Clause', 'bsd2clasue_license'])
    insert_kb_id('39692bc6-4d1c-4466-a02c-fa6f21170587', 'GPL2',
                 ['GPL-2.0+', 'GNU General Public License v2.0 or later'])
    insert_kb_id('cff110eb-f85c-445c-9d3b-00a04b7f4cf0', 'lgpl21',
                 ['LGPL-2.1+', 'GNU Lesser General Public License v2.1 or later'])
    # question public domain
    insert_kb_id('d26bcb7d-5bc8-4f05-8942-a3a42728a2e4', 'common_public', ['Public Domain', 'publicdomain'])
    insert_kb_id('ce59674b-e5f8-4e6e-b853-4203330abfb8', 'wtfpl_2', 'WTFPL')
    insert_kb_id('a7c69599-62b6-4d06-9ec6-ea688c041c00', 'CC0-1-0',
                 ['CC0-1.0', 'creativecommonscczerouniversalrightswaiver'])
    insert_kb_id('bf913382-7596-42ad-8385-2f49fa655362', 'lgpl3', ['LGPL-3.0+'])
    insert_kb_id('0d22d54d-3f73-4133-9f15-e84e50b22d0c', 'artistic_gpl', 'Artistic-1.0-Perl')
    insert_kb_id('8080f69c-46a3-4676-9bd8-f110d08f03ee', 'open_software', 'OSL-3.0')
    insert_kb_id('f80fb9a9-5329-47c2-864d-00ed5cf744bf', 'gpl3_or_later', 'GPL-3.0+')
    insert_kb_id('cb3238d3-5a3e-4506-a6e2-5054a6f07cdf', 'gpl', 'LGPL-2.0+')
    insert_kb_id('a7ad60dd-d542-49a7-9372-4f6531735106', 'Artistic_License_2_0', 'Artistic-2.0')
    insert_kb_id('537d3ece-558e-4181-a6c2-1cd0983817b9', 'academic', 'AFL-3.0')
    insert_kb_id('f5135f7b-f17e-473a-839b-3ea12860f761', 'gpl3', 'GPL-3.0')
    insert_kb_id('d676a5c4-0bd9-4453-8c22-2ece2c2a00d7', 'eclipse', ['EPL-1.0', 'EPL'])
    insert_kb_id('ce3dd63e-c569-4cea-986a-46bc5efe9896', 'mozilla_public_2_0', 'MPL-2.0')
    insert_kb_id('9c5d96e4-5639-4ea9-b17c-dcce18ca7930', 'GNU_General_Public_License_1_0', 'GPL-1.0+')
    insert_kb_id('8adc012e-9844-43ef-91cf-b45a3302c597', 'OpenSSL_License', 'The Open SSL License')
    insert_kb_id('6958c970-4ceb-419e-8316-206151b9714a', 'ccbysa3-0', 'CC-BY-3.0')
    insert_kb_id('27e99305-0410-4234-a7a5-e7efa1801cfd', 'CCBYSA4', 'CC-BY-4.0')
    insert_kb_id('0b9a55a6-7ff1-43ab-b9c7-2c7c7e8f35be', 'artistic', 'Artistic-1.0')
    insert_kb_id('347711ec-ba5f-48f3-9402-bd978c118eb2', 'x_net', 'Xnet')
    insert_kb_id('47d677c6-ab05-4984-ae45-83030d7c24b7', 'CC-BY-NC-SA-3-0', 'CC-BY-NC-SA-3.0')
    insert_kb_id('9f63ea0e-1486-40ff-844a-1536676b5400', 'BSD-4-Clause', 'BSD-4-Clause')
    insert_kb_id('ead40028-7962-4fc0-9be5-2b956cd4714a', 'Python-2-0', 'Python-2.0')
    insert_kb_id('89270f73-0920-4660-bf98-da4de1c75495', 'Academic_Free_License_v2_1', 'AFL-2.1')
    insert_kb_id('912a4957-ba62-4942-8616-aec7bc0eedec', 'ssleay', 'SSLeay License')

    # we dont have these licenses
    # insert_kb_id('21bd269c-2674-43d6-9d07-65d77e5a6ea3' 'libxml2License)
    # insert_kb_id('8fb456cc-8c55-4120-8676-8e3baa90c415' 'Alternative Commercial License Available'
    # insert_kb_id('479df888-20b3-4355-90fe-e5a9bf80c5ee' 'X11 License'
    # insert_kb_id('57b1f355-a0a0-4f5e-b4dd-019296e4eda6' 'Unlicense'
    # insert_kb_id('0507cbf4-6404-4033-b93e-9e0de2c11ae1','','mitv2withadclauselicense')
    # insert_kb_id('11290952-7cb0-492a-b312-ee675a8a9e5e' 'JasPer-2.0'
  end
  # rubocop:enable Metrics/AbcSize

  def insert_kb_id(kb_id, vanity_url, _kb_reference)
    sql = "Update licenses set kb_id = '#{kb_id}' where id =
        (select id from licenses where vanity_url = '#{vanity_url}') "

    ActiveRecord::Base.connection.execute sql
  end
end
