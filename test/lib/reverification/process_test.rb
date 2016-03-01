require 'test_helper'

class Reverification::ProcessTest < ActiveSupport::TestCase
  describe 'poll success queue' do
    describe 'initial phase' do
      before do
        @rev_tracker = create(:success_initial_rev_tracker)
        mock_queue = mock('AWS::SQS::Queue::MOCK')
        mock_queue.stubs(:poll).yields(SuccessMessage.new)
        Reverification::Process.stubs(:success_queue).returns(mock_queue)
      end

      it 'should retrieve a message in the queue and update rev_tracker to delivered' do
        Account.stubs(:find_by_email).with(@rev_tracker.account.email).returns(@rev_tracker.account)
        ReverificationTracker.any_instance.stubs(:pending?).returns(true)
        Reverification::Process.poll_success_queue
        assert ReverificationTracker.first.delivered?
      end

      it "should not update an account's rev_tracker to delivered if pending is false" do
        Account.stubs(:find_by_email).with(@rev_tracker.account.email).returns(@rev_tracker.account)
        ReverificationTracker.any_instance.stubs(:pending?).returns(false)
        ReverificationTracker.any_instance.expects(:delivered!).never
        Reverification::Process.poll_success_queue
      end
    end
  end

  describe 'poll bounce queue' do
    describe 'initial phase' do
      it 'should delete an account that returned a hard bounce' do
        create(:hard_bounce_initial_rev_tracker)
        mock_queue = mock('AWS::SQS::Queue::MOCK')
        mock_queue.stubs(:poll).yields(HardBounceMessage.new)
        Reverification::Process.stubs(:bounce_queue).returns(mock_queue)
        ReverificationTracker.expects(:destroy_account).with('bounce@simulator.amazonses.com')
        Reverification::Process.poll_bounce_queue
      end

      it 'should populate the transient bounce queue if a soft bounce is returned' do
        rev_tracker = create(:soft_bounce_initial_rev_tracker)
        mock_queue = mock('AWS::SQS::Queue::MOCK')
        mock_queue.stubs(:poll).yields(TransientBounceMessage.new)
        Reverification::Process.stubs(:bounce_queue).returns(mock_queue)
        ReverificationTracker.expects(:destroy_account).with('ooto@simulator.amazonses.com').never
        Account.stubs(:find_by_email).with('ooto@simulator.amazonses.com').returns(rev_tracker.account)
        ReverificationTracker.any_instance.expects(:soft_bounced!)
        # The bottom line is sending messages to the correct queue when it shouldnt
        # The mocking should stop it. Investigate.
        # AWS::SQS.any_instance.expects(:send_message).with('ooto@simulator.amazonses.com')
        Reverification::Process.poll_bounce_queue
      end

      it 'should update the rev_tracker to bounces if a soft bounce is returned' do
        create(:soft_bounce_initial_rev_tracker)
        mock_queue = mock('AWS::SQS::Queue::MOCK')
        mock_queue.stubs(:poll).yields(TransientBounceMessage.new)
        Reverification::Process.stubs(:bounce_queue).returns(mock_queue)
        Reverification::Process.poll_bounce_queue
        assert ReverificationTracker.first.soft_bounced?
      end

      it 'should populate the transient bounce queue if undetermined' do
        rev_tracker = create(:initial_rev_tracker)
        mock_queue = mock('AWS::SQS::Queue::MOCK')
        mock_queue.stubs(:poll).yields(UndeterminedMessage.new)
        Reverification::Process.stubs(:bounce_queue).returns(mock_queue)
        ReverificationTracker.expects(:destroy_account).with('someone@gmail.com').never
        Account.stubs(:find_by_email).with('someone@gmail.com').returns(rev_tracker.account)
        ReverificationTracker.any_instance.expects(:soft_bounced!)
        # The bottom line is sending messages to the correct queue when it shouldnt
        # The mocking should stop it. Investigate.
        # AWS::SQS.any_instance.expects(:send_message).with('someone@simulator.amazonses.com')
        Reverification::Process.poll_bounce_queue
      end
    end
  end

  describe 'poll transient bounce queue' do
    describe 'initial phase' do
      it 'should resend the first notification if found in the queue' do
        create(:soft_bounce_initial_rev_tracker)
        account = Account.last
        mock_queue = mock('AWS::SQS::Queue::MOCK')
        mock_queue.stubs(:poll).yields(TransientQueueMessage)
        Reverification::Process.stubs(:transient_bounce_queue).returns(mock_queue)
        Account.stubs(:find_by_email).with('ooto@simulator.amazonses.com').returns(account)
        ReverificationTracker.expects(:determime_correct_notification_to_send).with(account.reverification_tracker)
        Reverification::Process.poll_transient_bounce_queue
      end
    end
  end

  describe 'poll complaints queue' do
    describe 'initial phase' do
    end
  end
end