class PostRenderer < Hash
  def initialize opts
    self.person=opts[:person]
    self.post=opts[:post]
    self.aspects=opts[:person]
    self.comments=opts[:comments]
  end
  def aspects
    self[:aspects]
  end
  def aspects= new_aspect
    self[:aspects] = new_aspect
  end
  def post
    self[:post]
  end
  def post= new_post
    self[:post] = new_post
  end
  def person
    self[:person]
  end
  def person= new_person
    self[:person] = new_person
  end
  def comments
    self[:comments]
  end
  def comments= new_comments
    self[:comments] = new_comments.map{|c| CommentRenderer.new(c)}
  end
  def to_html
"<li class='message' data-guid='4cf4b8f2cc8cb40bec00001e'>
  <a href='/people/4ce97679cc8cb42ef9000003'>
    <img alt='Alexander Hamiltom' class='avatar' data-person_id='4ce97679cc8cb42ef9000003' src='/images/user/tom.jpg' title='Alexander Hamiltom'>
  </a>
  <div class='content'>
    <div class='from'>
      <a href='/people/4ce97679cc8cb42ef9000003'>
        Alexander Hamiltom
      </a>
      <div class='aspect'>
        \u2794
        <ul>
          <li>
            <a href='/aspects/4ce9767acc8cb42ef9000005'>
              Work
            </a>
          </li>
          <li>
            <a href='/aspects/4ce9767acc8cb42ef9000004'>
              Family
            </a>
          </li>
        </ul>
      </div>
      <div class='right'>
        <div class='reshare_pane'>
          <span class='reshare_button'>
            <a href=\"#\">
              Reshare
            </a>
          </span>
          <ul class='reshare_box'>
            <li class='aspect_to_share'>
              <a href=\"/aspects/4ce9767acc8cb42ef9000005?prefill=hey\">Work</a>
            </li>
            <li class='aspect_to_share'>
              <a href=\"/aspects/4ce9767acc8cb42ef9000004?prefill=hey\">Family</a>
            </li>
          </ul>
        </div>
        <a href=\"/status_messages/4cf4b8f2cc8cb40bec00001e\" class=\"delete\" data-confirm=\"Are you sure?\" data-method=\"delete\" data-remote=\"true\" rel=\"nofollow\">
          Delete
        </a>
      </div>
    </div>
    <p>
      hey
    </p>
    <div class='photo_attachments'>
      <a href=\"/photos/4cf4b8eccc8cb40bec00001d\"><img alt=\"Thumb_medium_ar027djoo04cf4b8eccc8cb40bec00001d\" src=\"/uploads/images/thumb_medium_aR027djoo04cf4b8eccc8cb40bec00001d.jpg?1291106542\" /></a>\n    
    </div>
    <div class='info'>
      <span class='time'>
        <a href=\"/status_messages/4cf4b8f2cc8cb40bec00001e\">less than a minute ago</a>
      </span>
      <a href=\"#\" class=\"show_post_comments\">show comments (0)</a>
    </div>
    <ul class='comments hidden' id='4cf4b8f2cc8cb40bec00001e'>
      <li class='comment show'>
        <form accept-charset=\"UTF-8\" action=\"/comments\" class=\"new_comment\" data-remote=\"true\" id=\"new_comment_on_4cf4b8f2cc8cb40bec00001e\" method=\"post\">
          <div style=\"margin:0;padding:0;display:inline\">
            <input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" />
            <input name=\"authenticity_token\" type=\"hidden\" value=\"1AZGI6+7XNlTllhb492ZnJe7kIQzIJqbyAoVeRHUWJA=\" />
          </div>
          <p>
            <label for=\"comment_text_on_4cf4b8f2cc8cb40bec00001e\">Comment</label>
            <textarea class=\"comment_box\" id=\"comment_text_on_4cf4b8f2cc8cb40bec00001e\" name=\"text\" rows=\"1\"></textarea>
          </p>
          <input id=\"post_id_on_4cf4b8f2cc8cb40bec00001e\" name=\"post_id\" type=\"hidden\" value=\"4cf4b8f2cc8cb40bec00001e\" />
          <input class=\"comment_submit button\" data-disable-with=\"Commenting...\" id=\"comment_submit_4cf4b8f2cc8cb40bec00001e\" name=\"commit\" type=\"submit\" value=\"Comment\" />
        </form>
      </li>
    </ul>
  </div>
</li>"
  end
end
