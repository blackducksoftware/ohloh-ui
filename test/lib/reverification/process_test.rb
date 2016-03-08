require 'test_helper'

class Reverification::ProcessTest < ActiveSupport::TestCase
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
      AWS::SimpleEmailService.any_instance.stubs(:send_email).returns(ses_send_mail_response)
      Reverification::Process.stubs(:ses_limit_reached?).returns(false)
    end
    let(:unverified_account) { create(:unverified_account) }

    it 'should not send email when daily send quota is reached' do
      Reverification::Process.stubs(:ses_limit_reached?).returns(true)
      AWS::SimpleEmailService.any_instance.expects(:send_email).never
      unverified_account.reverification_tracker.must_be_nil
      Reverification::Process.send_email('dummy email content', unverified_account, 0)
      unverified_account.reverification_tracker.must_be_nil
    end

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
        assert_equal Date.today, unverified_account.reverification_tracker.sent_at.to_date
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
        assert_equal Date.today, unverified_account.reverification_tracker.sent_at.to_date
      end
    end

    describe 'Resend notification' do
      before do
        Reverification::Process.send_email('dummy - first email content', unverified_account, 0)
        unverified_account.reverification_tracker.must_be :present?
        unverified_account.reverification_tracker.must_be :initial?
        unverified_account.reverification_tracker.must_be :pending?
        assert_equal 1, unverified_account.reverification_tracker.attempts
        assert_equal Date.today, unverified_account.reverification_tracker.sent_at.to_date
        unverified_account.reverification_tracker.soft_bounced!
        unverified_account.reverification_tracker.must_be :soft_bounced?
      end

      it 'should update reverification tracker attributes - status, attempts and sent_at' do
        Reverification::Process.send_email('dummy - first email content', unverified_account, 0)
        unverified_account.reverification_tracker.must_be :initial?
        unverified_account.reverification_tracker.must_be :pending?
        assert_equal 2, unverified_account.reverification_tracker.attempts
        assert_equal Date.today, unverified_account.reverification_tracker.sent_at.to_date
      end
    end
  end
end