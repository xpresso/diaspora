class PostRenderer < Hash
  include ApplicationHelper
  include ActionView::Helpers
  include StreamHelper
  GSUB_THIS = "___GSUB___THIS___".html_safe
  def initialize opts = {}
    self.person        = opts[:person]
    self.post          = opts[:post]
    self.aspects       = opts[:aspects]
    self.comments      = opts[:comments]
    self.photos        = opts[:photos]
    self.form_tag_text = opts[:form_tag_text]
  end
  def reshare_pane
    reshare_aspects = aspects_without_post(aspects, post)
    if reshare_aspects.empty?
      ""
    else
"<div class='reshare_pane'>
  <span class='reshare_button'>
    <a href=\"#\">
      Reshare
    </a>
  </span>
  <ul class='reshare_box'>
    #{aspect_links(reshare_aspects, :prefill => post.message)}
  </ul>
</div>
"
    end
  end
  def post_section
    str = "<p>
            #{markdownify(post.message, :youtube_maps => post[:youtube_titles])}
          </p>"
    if photos.count < 0
      str << "<div class='photo_attachments'>
        <a href=\"/photos/4cf4b8eccc8cb40bec00001d\"><img alt=\"Thumb_medium_ar027djoo04cf4b8eccc8cb40bec00001d\" src=\"/uploads/images/thumb_medium_aR027djoo04cf4b8eccc8cb40bec00001d.jpg?1291106542\" /></a>\n    
      </div>"
    end
    str
  end
  def comments_class
    cclass = "comments"
    cclass << "hidden" if comments.empty?
    cclass
  end
  def comment_lis
    str = ""
    comments.each{|c| str << c.to_html}
    str
  end
  def new_comment_form
    form_tag_text.gsub(GSUB_THIS, post.id.to_s)
  end
  def comments_section
    "<ul class='#{comments_class}' id='#{post.id}'>
      #{comment_lis}
      <li class='comment show'>
        #{new_comment_form}
      </li>
    </ul>"
  end
  def to_html
"<li class='message' data-guid='#{post.id}'>
  #{person_image_link(person)}
  <div class='content'>
    <div class='from'>
      #{person_link(person)}
      <div class='aspect'>
        ➔
        <ul>
          #{aspect_links(aspects_with_post(aspects, post))}
        </ul>
      </div>
      <div class='right'>
        #{reshare_pane}
        <a href=\"/status_messages/#{post.id}\" class=\"delete\" data-confirm=\"Are you sure?\" data-method=\"delete\" data-remote=\"true\" rel=\"nofollow\">
          Delete
        </a>
      </div>
    </div>
    #{post_section}
    <div class='info'>
      <span class='time'>
        <a href=\"/status_messages/#{post.id}\">
          #{how_long_ago(post)}
        </a>
      </span>
      #{comment_toggle(comments.length)}
    </div>
    #{comments_section}
  </div>
</li>"
  end
  def aspects
    self[:aspects]
  end
  def aspects= new_aspects
    self[:aspects] = new_aspects
  end
  def photos
    self[:photos]
  end
  def photos= new_photos
    self[:photos] = new_photos
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
  def form_tag_text
    self[:form_tag_text]
  end
  def form_tag_text= new_form_tag_text
    self[:form_tag_text] = new_form_tag_text
  end
  def protect_against_forgery?
    true
  end
end
