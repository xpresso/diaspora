module NotificationsHelper
  def object_link(note)
    kind = note.kind
    translation = t("notifications.#{kind}")
    case kind
    when 'request_accepted'
      translation
    when 'new_request'
      translation
    when 'comment_on_post'
      post = Post.first(:id => note.target_id)
      if post
        "#{translation} #{link_to t('notifications.post'), object_path(post)}".html_safe
      else
        "#{translation} #{t('notifications.deleted')} #{t('notifications.post')}"
      end
    when 'also_commented'
      comment = Comment.first(:id => note.target_id)
      if comment
        "#{translation} #{link_to t('notifications.post'), object_path(comment.post)}".html_safe
      else
        "#{translation} #{t('notifications.deleted')} #{t('notifications.post')}"
      end
    else
    end
  end

  def new_notification_text(count)
    if count > 0
      t('new_notifications', :count => count)
    else
      t('no_new_notifications')
    end
  end

  def new_notification_link(count)
    if count > 0
      link_to new_notification_text(count), notifications_path
    end
    def notification_people_link(note)
      note.people.collect{ |person| link_to("#{person.name.titlecase}", person_path(person))}.join(" , ").html_safe
    end

    def peoples_names(note)
      note.people.map{|p| p.name}.join(",")
    end
  end
end
