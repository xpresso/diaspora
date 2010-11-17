#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Retraction do

  let(:user) { make_user }
  let(:user2) { make_user }
  let(:user3) { make_user }
  let(:user4) { make_user }

  let(:aspect) { user.aspects.create(:name => "Bruisers") }
  let(:aspect2) { user2.aspects.create(:name => "Bruisers") }
  let(:aspect3) { user3.aspects.create(:name => "Bruisers") }
  let(:aspect4) { user4.aspects.create(:name => "Bruisers") }

  let(:person) { Factory(:person) }
  let!(:connect_users1) {connect_users(user, aspect, user2, aspect2)}
  let!(:connect_users2) {connect_users(user, aspect, user3, aspect3)}
  let!(:connect_users3) {connect_users(user2, aspect2, user4, aspect4)} #this is to test sending to send sending retractions upstream

  let!(:post) { user.post :status_message, :message => "Destroy!", :to => aspect.id }



  describe 'serialization' do
    it 'should have a post id after serialization' do
      retraction = Retraction.for(post)
      xml = retraction.to_xml.to_s
      xml.include?(post.id.to_s).should == true
    end
  end

  describe 'dispatching' do
    it 'should dispatch a message on destroy' do
      pending
      Factory.create :person
      User::QUEUE.should_receive :add_post_request
      post.destroy
    end
  end

  describe '#for' do
    context 'comments' do
      let!(:comment) {user.comment("excellent time", :on => post) }

      it 'sets the comment_id' do
        retraction = Retraction.for(comment)
        retraction.post_id.should == comment.id
      end
    end
  end

  describe '#perform_comment' do

    let!(:comment) {user.comment("excellent time", :on => post) }

    it 'retracts a comment with an valid signature' do
      retraction = Retraction.for(comment)
      retraction.comment_creator_signature = retraction.sign_with_key(user.encryption_key)

      lambda{ retraction.perform(user.id)}.should change(Comment, :count).by(-1)
    end

    it 'does not retract a comment with an invalid' do
      retraction = Retraction.for(comment)
      retraction.comment_creator_signature = "Invalid String"

      lambda{ retraction.perform(user.id) }.should raise_error /Comment Retraction with invalid signature/
    end
  end

  describe 'User#retract_coment' do
    let!(:comment) {user.comment("excellent time", :on => post) }
    let!(:comment2) {user2.comment("excellent time", :on => post) }

    it 'returns a retraction' do
      retraction = user.retract_comment(comment)
      retraction.type.should == 'Comment'
    end

    context 'signing' do
      it 'signs the retraction with the commentors key' do
        retraction = user.retract_comment(comment)
        retraction.comment_creator_signature.should_not be nil
        retraction.verify_signature retraction.comment_creator_signature, user.person
      end
    end

    context 'sending out' do
      it 'sends the retraction downstream' do
        user.should_receive(:push_to_person).twice
        user.retract_comment(comment)
      end

      it 'sends the retraction to the post owner' do
        user2.should_receive(:push_to_person).once
        user2.retract_comment(comment2)
      end
    end

    it 'retracts the comment on post by the author' do
      user2.reload.visible_posts.include?(post).should be true
      post.reload.comments.size.should == 2
      comment.should_not_receive(:destroy)
      it 'gets retracted correctly for the downstream user' do
        Retraction.any_instance.stubs(:perform_comment)

        user2.should_receive(:push_to_people)
        retraction = user2.retract_comment(comment2)

        user.should_receive(:push_to_person).once
        user.receive retraction.to_diaspora_xml, user2.person

        retraction.diaspora_handle = user.diaspora_handle
        user3.receive retraction.to_diaspora_xml, user.person

        proc{ comment2.reload}.should raise_error /does not exist/
          user.retract_comment(comment)
        post.reload.comments.size.should == 1
      end

      it 'retracts the comment on another persons post' do
        user.visible_posts.first.comments.include?(comment2)
        comment2.reload.should_not be_nil
        retraction = user2.retract_comment(comment2)
        proc{ comment2.reload}.should raise_error /does not exist/
      end

    end

  end
  describe "User#receive_retraction" do
    context 'Comment' do
      context 'upstream' do

        it 'retracts a comment sent upstream' do
          comment2   = user2.comment("excellent time", :on => post)
          retraction = user2.build_comment_retraction(comment2)
          xml        = retraction.to_diaspora_xml

          post.reload.comments.include?(comment2).should be true
          proc{ user.receive xml, user2.person }.should change(Comment, :count).by(-1)
          post.reload.comments.include?(comment2).should be false
        end

        it 'sends retractions to the downstream users' do
          pending
          comment2   = user2.comment("excellent time", :on => post)
          retraction = user2.build_comment_retraction(comment2)
          xml        = retraction.to_diaspora_xml

          user.should_receive(:push_to_people).once.with(any_args(), any_args(), "SDASDAS")#user3.person)
          post.reload.comments.include?(comment2).should be true
          proc{ user.receive xml, user2.person }.should change(Comment, :count).by(-1)
          post.reload.comments.include?(comment2).should be false
        end
      end

      context 'downstream' do
        it 'retracts a comment sent from the post owner' do
          comment    = user.comment("excellent time", :on => post)
          retraction = user.build_comment_retraction(comment)
          xml        = retraction.to_diaspora_xml

          post.reload.comments.include?(comment).should be true
          proc{ user3.receive xml, user.person }.should change(Comment, :count).by(-1)
          post.reload.comments.include?(comment).should be false
        end

        it 'retracts a comment sent from another commenter' do
          comment2   = user2.comment("excellent time", :on => post)
          retraction = user2.build_comment_retraction(comment2)
          retraction.diaspora_handle = user.diaspora_handle
          xml        = retraction.to_diaspora_xml

          post.reload.comments.include?(comment2).should be true
          proc{ user3.receive xml, user.person }.should change(Comment, :count).by(-1)
          post.reload.comments.include?(comment2).should be false
        end
        
        it 'does not retract a comment with an invalid signature' do
          comment2   = user2.comment("excellent time", :on => post)
          retraction = user2.build_comment_retraction(comment2)
          retraction.diaspora_handle = user.diaspora_handle
          retraction.comment_creator_signature = "NOT_SIGNATURE"
          xml        = retraction.to_diaspora_xml

          post.reload.comments.include?(comment2).should be true
          proc{ user3.receive xml, user.person }.should raise_error /Comment Retraction with invalid signature/
          post.reload.comments.include?(comment2).should be true
        end
      end

    end

  end
end


