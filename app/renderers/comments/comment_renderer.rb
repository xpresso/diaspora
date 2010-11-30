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
  <a href='/people/#{person.id}'>
    <img alt='#{person.real_name}' class='avatar' data-person_id='4ce97679cc8cb42ef9000002' src='#{image_or_default(person)}' title='#{person.real_name}'>
  </a>
  <div class='content'>
    <div class='from'>
      <a href='/people/#{person.id}'>
        Alexander Hamiltom
      </a>
    </div>
    iusdfbiuh
    <div class='time'>
      #{comment.created_at ? "#{time_ago_in_words(comment.created_at)} #{t('ago')}" : time_ago_in_words(Time.now)}
    </div>
  </div>
</li>"
  end
end
