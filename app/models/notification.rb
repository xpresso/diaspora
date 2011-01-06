#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
class Notification
  require File.join(Rails.root, 'lib/diaspora/web_socket')
  include MongoMapper::Document
  include Diaspora::Socketable

  key :target_id, ObjectId
  key :kind, String
  key :unread, Boolean, :default => true
  key :person_ids, Array, :typecast => 'ObjectId'

  belongs_to :user
  many :people, :class => Person, :in => :person_ids

  timestamps!

  attr_accessible :target_id, :kind, :user_id, :person_id, :unread

  def self.for(user, opts={})
    self.where(opts.merge!(:user_id => user.id)).order('created_at desc')
  end

  def self.notify(user, object, person)
    if object.respond_to? :notification_type
      if kind = object.notification_type(user, person)
        if object.is_a? Comment
          n = concatenate_or_create(user, object.post, person, kind)
        else
          n = make_notification(user, object, person, kind)
        end
        n.email_the_user(object, person) if n
        n.socket_to_uid(user, :actor => person) if n
        n
      end
    end
  end

  def email_the_user(object, person)
    case self.kind
    when "new_request"
      self.user.mail(Jobs::MailRequestReceived, self.user_id, person.id)
    when "request_accepted"
      self.user.mail(Jobs::MailRequestAcceptance, self.user_id, person.id)
    when "comment_on_post"
      self.user.mail(Jobs::MailCommentOnPost, self.user_id, person.id, object.id)
    when "also_commented"
      self.user.mail(Jobs::MailAlsoCommented, self.user_id, person.id, object.id)
    end
  end
private

  def self.concatenate_or_create(user, object, person, kind)
    if n = Notification.where(:target_id => object.id,
                               :kind => kind,
                               :user_id => user.id).first
      n.people << person
      n.save!
      n
    else
      n  = make_notification(user, object, person, kind)
    end
  end

  def self.make_notification(user, object, person, kind)
    n = Notification.new(:target_id => object.id,
                        :kind => kind,
                        :user_id => user.id)
    n.people << person
    n.save!
    n
  end
end
