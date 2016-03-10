require 'test_helper'
require 'test_helpers/reverification'

class Reverification::ProcessTest < ActiveSupport::TestCase
  before do
    AWS::SimpleEmailService.any_instance.stubs(:quotas).returns(MOCK::AWS::SimpleEmailService.send_quota)
    AWS::SQS.any_instance.stubs(:queues).returns(MOCK::AWS::SQS::QueueCollection.new)
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
  end

  describe 'send_email' do
    before do
      AWS::SimpleEmailService.any_instance.stubs(:send_email).returns(MOCK::AWS::SimpleEmailService.response)
    end
    let(:unverified_account) { create(:unverified_account) }

    describe 'First notification' do
      before do
        unverified_account.reverification_tracker.must_be_nil
      end

      it 'should create a reverification tracker' do
        Reverification::Process.send_email('dummy email content', unverified_account, 0)
        unverified_account.reverification_tracker.must_be :present?
        unverified_account.reverification_tracker.must_be :initial?
        unverified_account.reverification_tracker.must_be :pending?
        assert_equal 1, unverified_account.reverification_tracker.attempts
        assert_equal Time.zone.now.to_date, unverified_account.reverification_tracker.sent_at.to_date
      end
    end

    describe 'Second/subsequent notification' do
      before do
        Reverification::Process.send_email('dummy - first email content', unverified_account, 0)
        unverified_account.reverification_tracker.delivered!
      end

      it 'should update reverification tracker attributes - phase, status, attempts and sent_at' do
        Reverification::Process.send_email('dummy - second email content', unverified_account, 1)
        unverified_account.reverification_tracker.wont_be :initial?
        unverified_account.reverification_tracker.must_be :pending?
        assert_equal 1, unverified_account.reverification_tracker.attempts
        assert_equal Time.zone.now.to_date, unverified_account.reverification_tracker.sent_at.to_date
      end
    end

    describe 'Resend notification' do
      before do
        Reverification::Process.send_email('dummy - first email content', unverified_account, 0)
        unverified_account.reverification_tracker.must_be :present?
        unverified_account.reverification_tracker.must_be :initial?
        unverified_account.reverification_tracker.must_be :pending?
        assert_equal 1, unverified_account.reverification_tracker.attempts
        assert_equal Time.zone.now.to_date, unverified_account.reverification_tracker.sent_at.to_date
        unverified_account.reverification_tracker.soft_bounced!
        unverified_account.reverification_tracker.must_be :soft_bounced?
      end

      it 'should update reverification tracker attributes - status, attempts and sent_at' do
        Reverification::Process.send_email('dummy - first email content', unverified_account, 0)
        unverified_account.reverification_tracker.must_be :initial?
        unverified_account.reverification_tracker.must_be :pending?
        assert_equal 2, unverified_account.reverification_tracker.attempts
        assert_equal Time.zone.now.to_date, unverified_account.reverification_tracker.sent_at.to_date
      end
    end
  end

  describe 'cleanup' do
    it 'should invoke cleanup methods' do
      ReverificationTracker.expects(:remove_reverification_trackers_for_verifed_accounts)
      ReverificationTracker.expects(:delete_expired_accounts)
      Reverification::Process.cleanup
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
    it 'should return AWS::SQS instance' do
      Reverification::Process.expects(:sqs).returns(AWS::SQS)
      Reverification::Process.sqs
    end
  end

  describe 'success_queue' do
    it 'should return AWS::SQS::Queue instance for success queue' do
      queue_instance = Reverification::Process.success_queue
      queue_instance.url.must_match(/ses-success-queue/)
    end
  end

  describe 'bounce_queue' do
    it 'should return AWS::SQS::Queue instance for bounce queue' do
      queue_instance = Reverification::Process.bounce_queue
      queue_instance.url.must_match(/ses-bounces-queue/)
    end
  end

  describe 'complaints_queue' do
    it 'should return AWS::SQS::Queue instance for complaints queue' do
      queue_instance = Reverification::Process.complaints_queue
      queue_instance.url.must_match(/ses-complaints-queue/)
    end
  end

  describe 'ses_limit_reached?' do
    it 'should return false when daily sent quota not reached max daily send quota' do
      assert_equal false, Reverification::Process.ses_limit_reached?
    end
  end

  describe 'ses_daily_limit_available' do
    it 'should return the balance send limit available for the day' do
      assert_equal 150, Reverification::Process.ses_daily_limit_available
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

  describe 'update_reverification' do
    before do
      @rev_tracker = create(:reverification_tracker)
    end

    it 'should increment attempts when phase equals the phase value' do
      Reverification::Process.update_tracker(@rev_tracker, 0, MOCK::AWS::SimpleEmailService.response)
      assert_equal 2, @rev_tracker.attempts
      assert_equal MOCK::AWS::SimpleEmailService.response[:message_id], @rev_tracker.message_id
      assert_equal 'pending', @rev_tracker.status
      assert_equal 'initial', @rev_tracker.phase
      assert_equal @rev_tracker.sent_at.to_date, Time.now.utc.to_date
    end

    it 'should reset attempts to 1 when phase does not match phase value' do
      Reverification::Process.update_tracker(@rev_tracker, 1, MOCK::AWS::SimpleEmailService.response)
      assert_equal 1, @rev_tracker.attempts
      assert_equal MOCK::AWS::SimpleEmailService.response[:message_id], @rev_tracker.message_id
      assert_equal 'pending', @rev_tracker.status
      assert_equal 'marked_for_spam', @rev_tracker.phase
      assert_equal @rev_tracker.sent_at.to_date, Time.now.utc.to_date
    end
  end
end
