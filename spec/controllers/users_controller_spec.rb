#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe UsersController do

  let(:user) { make_user }
  let!(:aspect) { user.aspects.create(:name => "lame-os") }

  let!(:old_password) { user.encrypted_password }
  let!(:old_language) { user.language }
    
  before do
    sign_in :user, user
  end

  describe '#export' do
    it 'should return an xml file'  do
      get :export
      response.header["Content-Type"].should include "application/xml"
    end
  end

  describe '#update' do
    context 'updating private profile' do
      def make_request
        put :update, "id" => user.id.to_s, "user"=> @priv_profile_params
      end

      before do
        @priv_profile_params = { "private_profile" =>
          { "image" => "",
            "last_name"  => user.person.profile.last_name,
            "first_name" => user.person.profile.first_name,
            "date" => {"year" => "1980", "month" => "12", "day" => "25"},
            "gender" => "M",
            "bio" => "Hello world" }}
      end

      it 'sets flash notice on success' do
        make_request
        flash[:notice].should_not be_blank
      end

      context 'user does not have a private profile' do
        it 'creates the users private profile' do
          user.private_profile.should be_nil
          make_request
          user.reload.private_profile.last_name.should == user.person.profile.last_name
          user.reload.private_profile.first_name.should == user.person.profile.first_name
        end
      end

      context 'user already has a profile' do
        it 'updates the users private profile' do
          user.private_profile = PrivateProfile.new(:first_name => "Whoever")
          user.save!
          make_request
          user.reload.private_profile.first_name.should_not == "Whoever"
        end
      end
    end

    it "doesn't overwrite random attributes" do
      params  = {:diaspora_handle => "notreal@stuff.com"}
      proc{ put 'update', :id => user.id.to_s, "user" => params }.should_not change(user, :diaspora_handle)
    end

    context 'should allow the user to update their password' do
      it 'should change a users password ' do
        put("update", :id => user.id.to_s, "user"=> {"password" => "foobaz", 'password_confirmation' => "foobaz"})
        user.reload
        user.encrypted_password.should_not == old_password
      end

      it 'should not change a password if they do not match' do
        put("update", :id => user.id.to_s, "user"=> {"password" => "foobarz", 'password_confirmation' => "not_the_same"})
        user.reload
        user.encrypted_password.should == old_password
      end

      it 'should not update if the password fields are left blank' do
        put("update", :id => user.id.to_s, "user"=> {"password" => "", 'password_confirmation' => ""})
        user.reload
        user.encrypted_password.should == old_password
      end
    end

    describe 'language' do
      it 'should allow user to change his language' do
        user.language = 'en'
        user.save
        old_language = user.language
        put("update", :id => user.id.to_s, "user" => {"language" => "fr"})
        user.reload
        user.language.should_not == old_language
      end
    end
  end
end
