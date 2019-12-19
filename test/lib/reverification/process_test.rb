# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/reverification'

class Reverification::ProcessTest < ActiveSupport::TestCase
  before do
    Aws::SES::Client.any_instance.stubs(:get_send_quota).returns(MOCK::AWS::SimpleEmailService.send_quota)
    under_bounce_limit = MOCK::AWS::SimpleEmailService.under_bounce_limit
    Aws::SES::Client.any_instance.stubs(:get_send_statistics).returns(under_bounce_limit)
    Aws::SQS::Resource.any_instance.stubs(:queues).returns(MOCK::AWS::SQS::QueueCollection.new)
  end

  describe 'poll success queue' do
    before do
      mock_queue = mock('AWS::SQS::Queue::MOCK')
      mock_queue.stubs(:poll).yields(SuccessMessage.new)
      Reverification::Process.stubs(:success_queue).returns(mock_queue)
    end

    it 'should retrieve a message in the queue and update rev_tracker to delivered' do
      rev_tracker = create(:success_initial_rev_tracker, status: 0)
      assert rev_tracker.pending?
      Reverification::Process.poll_success_queue
      rev_tracker.reload
      assert rev_tracker.delivered?
    end

    it "should not update an account's rev_tracker to delivered if status is not pending" do
      rev_tracker = create(:success_initial_rev_tracker, status: 2)
      rev_tracker.wont_be :pending?
      Reverification::Process.poll_success_queue
      rev_tracker.reload
      rev_tracker.wont_be :delivered?
    end

    it 'should skip to polling next feedback notification when reverification tracker does not exist' do
      rev_tracker = create(:success_initial_rev_tracker, status: 0)
      rev_tracker.destroy
      ReverificationTracker.any_instance.expects(:pending?).never
      ReverificationTracker.any_instance.expects(:delivered?).never
      Reverification::Process.poll_success_queue
    end

    it 'should skip to polling next feedback notification if email address is not matching any account' do
      rev_tracker = create(:success_initial_rev_tracker, status: 0)
      rev_tracker.account.update_attribute(:email, 'test@test.com')
      ReverificationTracker.any_instance.expects(:pending?).never
      ReverificationTracker.any_instance.expects(:delivered!).never
      Reverification::Process.poll_success_queue
    end
  end

  describe 'poll bounce queue' do
    let(:mock_queue) { mock('AWS::SQS::Queue::MOCK') }
    let(:hard_bounce_account) { create(:unverified_account, :hard_bounce) }
    let(:soft_bounce_account) { create(:unverified_account, :soft_bounce) }
    let(:bounce_undetermined_account) { create(:unverified_account, :bounce_undetermined) }

    before do
      create(:reverification_tracker, account: hard_bounce_account)
      create(:reverification_tracker, account: soft_bounce_account)
      create(:reverification_tracker, account: bounce_undetermined_account)
    end

    describe 'hard bounce' do
      it 'should delete the account' do
        mock_queue.stubs(:poll).yields(HardBounceMessage.new)
        Reverification::Process.stubs(:bounce_queue).returns(mock_queue)
        hard_bounce_account.must_be :present?
        hard_bounce_account.reverification_tracker.must_be :present?
        Reverification::Process.poll_bounce_queue
        Account.find_by(id: hard_bounce_account.id).must_be_nil
        ReverificationTracker.find_by(id: hard_bounce_account.reverification_tracker.id).must_be_nil
      end
    end

    describe 'soft bounce' do
      it 'should update the reverification tracker status to soft_bounced' do
        mock_queue.stubs(:poll).yields(TransientBounceMessage.new)
        Reverification::Process.stubs(:bounce_queue).returns(mock_queue)
        soft_bounce_account.reverification_tracker.wont_be :soft_bounced?
        Reverification::Process.poll_bounce_queue
        soft_bounce_account.reload.reverification_tracker.must_be :soft_bounced?
      end
    end

    describe 'undetermined bounce' do
      it 'should update the reverification tracker status to soft_bounced' do
        mock_queue.stubs(:poll).yields(UndeterminedBounceMessage.new)
        Reverification::Process.stubs(:bounce_queue).returns(mock_queue)
        bounce_undetermined_account.reverification_tracker.wont_be :soft_bounced?
        Reverification::Process.poll_bounce_queue
        bounce_undetermined_account.reload.reverification_tracker.must_be :soft_bounced?
      end
    end

    it 'should skip to polling next feedback notification if email address is not matching any account' do
      mock_queue.stubs(:poll).yields(TransientBounceMessage.new)
      Reverification::Process.stubs(:bounce_queue).returns(mock_queue)
      soft_bounce_account.update_attribute(:email, 'test@test.com')
      ReverificationTracker.expects(:destroy_account).never
      ReverificationTracker.any_instance.expects(:soft_bounced!).never
      Reverification::Process.poll_bounce_queue
    end
  end

  describe 'poll complaints queue' do
    let(:complained_account) { create(:unverified_account, :complaint) }

    before do
      create(:reverification_tracker, account: complained_account)
      mock_queue = mock('AWS::SQS::Queue::MOCK')
      mock_queue.stubs(:poll).yields(ComplaintMessage.new)
      Reverification::Process.stubs(:complaints_queue).returns(mock_queue)
    end

    it 'should update reverification tracker status to complained' do
      complained_account.reverification_tracker.wont_be :complained?
      Reverification::Process.poll_complaints_queue
      complained_account.reload.reverification_tracker.must_be :complained?
    end

    it 'should skip to polling next feedback notification if email address is not matching any account' do
      complained_account.update_attribute(:email, 'test@test.com')
      ReverificationTracker.any_instance.expects(:complained!).never
      Reverification::Process.poll_complaints_queue
    end
  end

  describe 'start_polling_queues' do
    it 'should invoke polling queues' do
      Reverification::Process.expects(:poll_success_queue)
      Reverification::Process.expects(:poll_bounce_queue)
      Reverification::Process.expects(:poll_complaints_queue)
      Reverification::Process.start_polling_queues
    end
  end

  describe 'sqs' do
    it 'should return Aws::SQS::Resource instance' do
      Reverification::Process.expects(:sqs).returns(Aws::SQS::Resource)
      Reverification::Process.sqs
    end
  end

  describe 'success_queue' do
    it 'should return AWS::SQS::Queue instance for success queue' do
      queue_instance = Reverification::Process.success_queue
      queue_instance.url.must_match(/success-queue/)
    end
  end

  describe 'bounce_queue' do
    it 'should return AWS::SQS::Queue instance for bounce queue' do
      queue_instance = Reverification::Process.bounce_queue
      queue_instance.url.must_match(/bounces-queue/)
    end
  end

  describe 'complaints_queue' do
    it 'should return AWS::SQS::Queue instance for complaints queue' do
      queue_instance = Reverification::Process.complaints_queue
      queue_instance.url.must_match(/complaints-queue/)
    end
  end

  describe 'bad_email_queue' do
    it 'should return AWS::SQS::Queue instance for badly formatted emails queue' do
      queue_instance = Reverification::Process.bad_email_queue
      queue_instance.url.must_match(/bad-email-queue/)
    end
  end

  describe 'check_statistics_of_last_24_hrs' do
    it 'should raise SimpleEmailServiceLimitError if bounce rate is above 5%' do
      over_bounce_limit = MOCK::AWS::SimpleEmailService.over_bounce_limit
      Aws::SES::Client.any_instance.stubs(:get_send_statistics).returns(over_bounce_limit)
      Aws::SES::Client.any_instance.stubs(:get_send_quota).returns(stub(sent_last_24_hours: 1000))
      Reverification::Process.stubs(:amazon_stat_settings).returns(bounce_rate: 5.0, amount_of_email: 1001.0)
      assert_raise Reverification::ExceptionHandlers::BounceRateLimitError do
        Reverification::Process.check_statistics_of_last_24_hrs
      end
    end

    it 'should not raise SimpleEmailServiceLimitError if bounce rate is below 5%' do
      under_bounce_limit = MOCK::AWS::SimpleEmailService.under_bounce_limit
      Aws::SES::Client.any_instance.stubs(:get_send_statistics).returns(under_bounce_limit)
      Aws::SES::Client.any_instance.stubs(:get_send_quota).returns(stub(sent_last_24_hours: 60))
      Reverification::Process.stubs(:amazon_stat_settings).returns(bounce_rate: 5.0, amount_of_email: 100.0)
      assert_nothing_raised Reverification::ExceptionHandlers::BounceRateLimitError do
        Reverification::Process.check_statistics_of_last_24_hrs
      end
    end

    it 'should raise SimpleEmailServiceLimitError if complaint rate is above 0.1%' do
      over_complaint_limit = MOCK::AWS::SimpleEmailService.over_complaint_limit
      Aws::SES::Client.any_instance.stubs(:get_send_statistics).returns(over_complaint_limit)
      Aws::SES::Client.any_instance.stubs(:get_send_quota).returns(stub(sent_last_24_hours: 2000))
      Reverification::Process.stubs(:amazon_stat_settings).returns(bounce_rate: 5.0, amount_of_email: 1001.0)
      assert_raise Reverification::ExceptionHandlers::ComplaintRateLimitError do
        Reverification::Process.check_statistics_of_last_24_hrs
      end
    end

    it 'should not raise SimpleEmailServiceLimitError if complaint rate is below 0.1%' do
      under_complaint_limit = MOCK::AWS::SimpleEmailService.under_complaint_limit
      Aws::SES::Client.any_instance.stubs(:get_send_statistics).returns(under_complaint_limit)
      Aws::SES::Client.any_instance.stubs(:get_send_quota).returns(stub(sent_last_24_hours: 1000))
      Reverification::Process.stubs(:amazon_stat_settings).returns(bounce_rate: 5.0, amount_of_email: 1001.0)
      assert_nothing_raised Reverification::ExceptionHandlers::ComplaintRateLimitError do
        Reverification::Process.check_statistics_of_last_24_hrs
      end
    end

    it 'should not be invoked if sent_last_24_hours is less than specified email amount' do
      Aws::SES::Client.any_instance.stubs(:send_email).returns(MOCK::AWS::SimpleEmailService.response)
      amazon_stat_settings = MOCK::AWS::SimpleEmailService.amazon_stat_settings
      Reverification::Process.stubs(:sent_last_24_hrs).returns(999.0)
      Reverification::Process.stubs(:amazon_stat_settings).returns(amazon_stat_settings)
      Reverification::Process.expects(:check_statistics_of_last_24_hrs).never
    end
  end

  describe 'handle_bounce_notification' do
    it 'should execute destroy accoun if type is Permanent' do
      create(:hard_bounce_initial_rev_tracker)
      ReverificationTracker.expects(:destroy_account).with('bounce@simulator.amazonses.com')
      ReverificationTracker.any_instance.expects(:soft_bounced!).never
      Reverification::Process.handle_bounce_notification('Permanent', 'bounce@simulator.amazonses.com')
    end

    it 'should execute rev_tracker.soft_bounced when Transient' do
      create(:soft_bounce_initial_rev_tracker)
      ReverificationTracker.any_instance.expects(:soft_bounced!)
      Reverification::Process.handle_bounce_notification('Undetermined', 'ooto@simulator.amazonses.com')
    end

    it 'should execute rev_tracker.soft_bounced when Undetermined' do
      create(:soft_bounce_initial_rev_tracker)
      ReverificationTracker.any_instance.expects(:soft_bounced!)
      Reverification::Process.handle_bounce_notification('Undetermined', 'ooto@simulator.amazonses.com')
    end
  end

  describe 'set_amazon_stat_settings' do
    it 'should set bounce rate benchmark and amount of email' do
      Reverification::Process.set_amazon_stat_settings(5.0, 1000.0)
      assert_equal Reverification::Process.amazon_stat_settings, MOCK::AWS::SimpleEmailService.amazon_stat_settings
    end
  end
end
