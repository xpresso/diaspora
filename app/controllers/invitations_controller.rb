#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class InvitationsController < Devise::InvitationsController

  before_filter :check_token, :only => [:edit]


  def create
      if current_user.invites == 0
        flash[:error] = I18n.t 'invitations.create.no_more'
        redirect_to :back
        return
      end
      aspect = params[:user].delete(:aspects)
      message = params[:user].delete(:invite_messages)
      emails = params[:user][:email].split(/, */)

      bad_messages = []
      good_emails, bad_emails = emails.partition{|e| e.try(:match, Devise.email_regexp)}

      good_emails.each do |e| 
        r =  Invitation.invite(:from => current_user, :into => aspect, :message => message, :email => e)
        if r.class.name == "String"
          bad_messages << r
        end
      end

      if bad_emails.any? || bad_messages.any?
        flash[:error] = I18n.t('invitations.create.sent') + good_emails.join(', ') + " "+ I18n.t('invitations.create.rejected') + bad_emails.join(', ') + bad_messages.join(', ')
      else
        flash[:notice] = I18n.t('invitations.create.sent') + good_emails.join(', ')
      end

    redirect_to :back
  end

  def update
    begin
      invitation_token = params[:user][:invitation_token]
      if invitation_token.nil? || invitation_token.blank?
        raise I18n.t('invitations.check_token.not_found')
      end
      user = User.find_by_invitation_token(params[:user][:invitation_token])
      user.seed_aspects
      user.accept_invitation!(params[:user])
    rescue Exception => e
      user = nil
      flash[:error] = e.message
    end

    if user
      flash[:notice] = I18n.t 'registrations.create.success'
      sign_in_and_redirect(:user, user)
    else
      redirect_to accept_user_invitation_path(
        :invitation_token => params[:user][:invitation_token])
    end
  end

  protected

  def check_token
    if User.find_by_invitation_token(params[:invitation_token]).nil?
      flash[:error] = I18n.t 'invitations.check_token.not_found'
      redirect_to root_url
    end
  end
end
