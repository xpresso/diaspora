#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Invitation
  include MongoMapper::Document

  belongs_to :from, :class => User
  belongs_to :to, :class => User
  belongs_to :into, :class => Aspect
  key :message, String

  validates_presence_of :from, :to, :into

  def self.invite(opts = {})
    return false if opts[:email] == opts[:from].email
    existing_user = User.find_by_email(opts[:email])
    if existing_user
      if opts[:from].contact_for(opts[:from].person)
        return "You are already connceted to #{opts[:email]}"
      elsif not existing_user.invited?
        opts[:from].send_contact_request_to(existing_user.person, opts[:into])
        return
      elsif Invitation.first(:from_id => opts[:from].id, :to_id => existing_user.id)
        return "You already invited #{opts[:email]}"
      end
    else
      Resque.enqueue(Jobs::InviteUser, opts[:from].id, opts[:email], opts[:into], opts[:message])
      return nil
    end
  end

  def self.create_invitee(opts = {})
    invitee = User.new_or_existing_user_by_email(opts[:email])
    return invitee unless opts[:email].match Devise.email_regexp
    invitee.invites = opts[:invites]
    if invitee.new_record?
      invitee.errors.clear
      invitee.serialized_private_key ||= User.generate_key
      invitee.send(:generate_invitation_token)
    elsif invitee.invitation_token.nil?
      return invitee
    end

    if opts[:from]
      invitee.save(:validate => false)
      Invitation.create!(:from => opts[:from],
                         :to => invitee,
                         :into => opts[:into],
                         :message => opts[:message])

      opts[:from].invites -= 1 unless opts[:from].invites == 0
      opts[:from].save!
      invitee.reload
    end

    invitee.invite! 
    Rails.logger.info("event=invitation_sent to=#{opts[:email]} #{"inviter=#{opts[:from].diaspora_handle}" if opts[:from]}")
    invitee
  end

  def to_request!
    request = from.send_contact_request_to(to.person, into)
    destroy if request
    request
  end
end
