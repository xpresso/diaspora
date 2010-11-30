class CommentRenderer < Hash
  include ApplicationHelper
  include ActionView::Helpers
  def person
    self[:person]
  end
  def person= new_person
    self[:person] = new_person
  end
  def comment
    self[:comment]
  end
  def comment= new_comment
    self[:comment] = new_comment
  end
  def initialize opts
    self.person=opts[:person]
    self.comment=opts[:comment]
  end
  def to_html
"<li class='comment' data-guid='#{comment.id}'>
  #{person_image_link(person)}
  <div class='content'>
    <div class='from'>
      #{person_link(person)}
    </div>
    #{markdownify(comment.text, :youtube_maps => comment[:youtube_titles])}
    <div class='time'>
      #{comment.created_at ? "#{time_ago_in_words(comment.created_at)} #{t('ago')}" : time_ago_in_words(Time.now)}
    </div>
  </div>
</li>"
  end
end
