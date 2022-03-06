# frozen_string_literal: true

require 'test_helper'

class CloudTagTest < ActiveSupport::TestCase
  let(:tag_list) do
    [['blog', 206], ['c++', 421], ['cms', 290], ['collaboration', 195], ['community', 242],
     ['content_management', 223], ['cross-platform', 385], ['design', 202], ['development', 499],
     ['dts', 195], ['dvb', 193], ['framework', 513], ['java', 345], ['library', 241], ['linux', 445],
     ['management', 218], ['mvc', 226], ['mysql', 328], ['php', 409], ['podcast', 193], ['portal', 194],
     ['python', 271], ['remote', 189], ['rtsp', 195], ['site_management', 215], ['streaming', 198], ['upnp', 195],
     ['video', 236], ['web', 414], ['windows', 310]]
  end

  describe 'list' do
    it 'should return a tag list based on the day' do
      Time.any_instance.stubs(:day).returns(24)
      _(CloudTag.list).must_equal tag_list
    end
  end
end
