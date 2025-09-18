# frozen_string_literal: true

require 'test_helper'

class CodeopenhubTest < ActiveSupport::TestCase
  describe 'Codeopenhub constraint' do
    before do
      @original_subdomain = ENV.fetch('CODE_SUBDOMAIN', nil)
    end

    after do
      ENV['CODE_SUBDOMAIN'] = @original_subdomain
    end

    describe '.matches?' do
      it 'should return true when CODE_SUBDOMAIN matches request subdomain' do
        ENV['CODE_SUBDOMAIN'] = 'code'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('code')

        _(Codeopenhub.matches?(mock_request)).must_equal true
      end

      it 'should return true when request subdomain contains CODE_SUBDOMAIN' do
        ENV['CODE_SUBDOMAIN'] = 'code'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('codecoverage')

        _(Codeopenhub.matches?(mock_request)).must_equal true
      end

      it 'should return false when request subdomain does not contain CODE_SUBDOMAIN' do
        ENV['CODE_SUBDOMAIN'] = 'code'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('api')

        _(Codeopenhub.matches?(mock_request)).must_equal false
      end

      it 'should return false when CODE_SUBDOMAIN is empty' do
        ENV['CODE_SUBDOMAIN'] = ''
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('code')

        _(Codeopenhub.matches?(mock_request)).must_equal false
      end

      it 'should return false when CODE_SUBDOMAIN is nil' do
        ENV['CODE_SUBDOMAIN'] = nil
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('code')

        _(Codeopenhub.matches?(mock_request)).must_equal false
      end

      it 'should handle empty request subdomain' do
        ENV['CODE_SUBDOMAIN'] = 'code'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('')

        _(Codeopenhub.matches?(mock_request)).must_equal false
      end

      it 'should handle nil request subdomain' do
        ENV['CODE_SUBDOMAIN'] = 'code'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns(nil)

        assert_raises(NoMethodError) do
          Codeopenhub.matches?(mock_request)
        end
      end

      it 'should be case sensitive' do
        ENV['CODE_SUBDOMAIN'] = 'code'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('CODE')

        _(Codeopenhub.matches?(mock_request)).must_equal false
      end

      it 'should work with complex subdomains' do
        ENV['CODE_SUBDOMAIN'] = 'api'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('api-v2.staging')

        _(Codeopenhub.matches?(mock_request)).must_equal true
      end

      it 'should handle partial matches correctly' do
        ENV['CODE_SUBDOMAIN'] = 'cod'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('code')

        _(Codeopenhub.matches?(mock_request)).must_equal true
      end

      it 'should handle subdomain at the beginning' do
        ENV['CODE_SUBDOMAIN'] = 'test'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('testing')

        _(Codeopenhub.matches?(mock_request)).must_equal true
      end

      it 'should handle subdomain in the middle' do
        ENV['CODE_SUBDOMAIN'] = 'api'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('v1-api-staging')

        _(Codeopenhub.matches?(mock_request)).must_equal true
      end

      it 'should handle subdomain at the end' do
        ENV['CODE_SUBDOMAIN'] = 'code'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('staging-code')

        _(Codeopenhub.matches?(mock_request)).must_equal true
      end
    end

    describe 'environment variable handling' do
      it 'should read CODE_SUBDOMAIN environment variable' do
        ENV['CODE_SUBDOMAIN'] = 'custom'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('custom')

        _(Codeopenhub.matches?(mock_request)).must_equal true
      end

      it 'should handle whitespace in environment variable' do
        ENV['CODE_SUBDOMAIN'] = '  code  '
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('code')

        # The current implementation doesn't trim, so this should fail
        _(Codeopenhub.matches?(mock_request)).must_equal false
      end

      it 'should use default empty string when environment variable is not set' do
        ENV.delete('CODE_SUBDOMAIN')
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('anything')

        _(Codeopenhub.matches?(mock_request)).must_equal false
      end

      it 'should re-read environment variable on each call' do
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('dynamic')

        ENV['CODE_SUBDOMAIN'] = 'dynamic'
        _(Codeopenhub.matches?(mock_request)).must_equal true

        ENV['CODE_SUBDOMAIN'] = 'different'
        _(Codeopenhub.matches?(mock_request)).must_equal false
      end
    end

    describe 'Rails routing integration' do
      it 'should work as Rails routing constraint' do
        ENV['CODE_SUBDOMAIN'] = 'code'

        # Simulate Rails request object
        rails_request = mock('ActionDispatch::Request')
        rails_request.stubs(:subdomain).returns('code')

        _(Codeopenhub.matches?(rails_request)).must_equal true
      end

      it 'should respond to matches? class method as required by Rails constraints' do
        _(Codeopenhub).must_respond_to :matches?
        _(Codeopenhub.method(:matches?).arity).must_equal 1
      end

      it 'should handle request objects with additional methods' do
        ENV['CODE_SUBDOMAIN'] = 'api'

        complex_request = mock('request')
        complex_request.stubs(:subdomain).returns('api')
        complex_request.stubs(:host).returns('api.example.com')
        complex_request.stubs(:port).returns(80)
        complex_request.stubs(:path).returns('/v1/projects')

        _(Codeopenhub.matches?(complex_request)).must_equal true
      end
    end

    describe 'edge cases' do
      it 'should handle request object without subdomain method' do
        ENV['CODE_SUBDOMAIN'] = 'code'
        invalid_request = Object.new

        assert_raises(NoMethodError) do
          Codeopenhub.matches?(invalid_request)
        end
      end

      it 'should handle nil request object' do
        ENV['CODE_SUBDOMAIN'] = 'code'

        assert_raises(NoMethodError) do
          Codeopenhub.matches?(nil)
        end
      end

      it 'should handle special characters in subdomain' do
        ENV['CODE_SUBDOMAIN'] = 'test-api'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('test-api-v1')

        _(Codeopenhub.matches?(mock_request)).must_equal true
      end

      it 'should handle numbers in subdomain' do
        ENV['CODE_SUBDOMAIN'] = 'v2'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('api-v2-staging')

        _(Codeopenhub.matches?(mock_request)).must_equal true
      end

      it 'should handle underscores in subdomain' do
        ENV['CODE_SUBDOMAIN'] = 'test_api'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('test_api_v1')

        _(Codeopenhub.matches?(mock_request)).must_equal true
      end
    end

    describe 'string inclusion behavior' do
      it 'should not perform regex matching' do
        ENV['CODE_SUBDOMAIN'] = 'a.*'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('api')

        # Should treat as literal string, not regex pattern
        _(Codeopenhub.matches?(mock_request)).must_equal false
      end

      it 'should not perform wildcard matching' do
        ENV['CODE_SUBDOMAIN'] = 'cod*'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('code')

        # Should treat as literal string, not wildcard pattern
        _(Codeopenhub.matches?(mock_request)).must_equal false
      end
    end

    describe 'real-world scenarios' do
      it 'should match code subdomain in production' do
        ENV['CODE_SUBDOMAIN'] = 'code'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('code')

        _(Codeopenhub.matches?(mock_request)).must_equal true
      end

      it 'should match code subdomain in staging environment' do
        ENV['CODE_SUBDOMAIN'] = 'code'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('code-staging')

        _(Codeopenhub.matches?(mock_request)).must_equal true
      end

      it 'should not match main site subdomain' do
        ENV['CODE_SUBDOMAIN'] = 'code'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('www')

        _(Codeopenhub.matches?(mock_request)).must_equal false
      end

      it 'should not match api subdomain when looking for code' do
        ENV['CODE_SUBDOMAIN'] = 'code'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('api')

        _(Codeopenhub.matches?(mock_request)).must_equal false
      end

      it 'should handle development environment with localhost' do
        ENV['CODE_SUBDOMAIN'] = 'code'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('code')

        _(Codeopenhub.matches?(mock_request)).must_equal true
      end
    end

    describe 'performance considerations' do
      it 'should be efficient for multiple calls' do
        ENV['CODE_SUBDOMAIN'] = 'api'
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('api-v1')

        # Should handle multiple calls efficiently
        100.times do
          _(Codeopenhub.matches?(mock_request)).must_equal true
        end
      end

      it 'should not cache environment variable reads' do
        mock_request = mock('request')
        mock_request.stubs(:subdomain).returns('test')

        # Should read environment variable on each call
        ENV.expects(:[]).with('CODE_SUBDOMAIN').returns('test').times(3)

        3.times { Codeopenhub.matches?(mock_request) }
      end
    end
  end
end
