require 'spec_helper'
describe PostRenderer do
  before do
    @user = make_user
    @aspect = @user.aspects.create(:name => 'strangers')
    @user.aspects.create(:name => 'wagoneers')
    @user.aspects.create(:name => 'cannoneers')
    @post = @user.post :status_message, :message => 'hello', :to => @aspect.id
    @comments = []
    10.times do
      comment = @user.comment 'anyone there?', :on => @post
      @comments << {:comment => comment,
        :person => comment.person}
    end
    @form_tag_text = SampleController.new.render_to_string(
      :partial => 'comments/new_comment',
      :locals => {:post_id => PostRenderer::GSUB_THIS}
    )
    @post_hash = {
      :form_tag_text => @form_tag_text,
      :current_user => @user,
      :post => @post,
      :photos => @post.photos,
      :aspects => @user.aspects,
      :comments => @comments,
        :person => @user.person}
    @renderer = PostRenderer.new(@post_hash)
  end
  it 'has a post' do
    @renderer.post.should == @post
  end
  it 'has a person' do
    @renderer.person.should == @user.person
  end
  it 'has photos' do
    @renderer.photos.should == @post.photos
  end
  it 'has aspects' do
    @renderer.aspects.should == @user.aspects
  end
  it 'has form tag text' do
    @renderer.form_tag_text.should == @form_tag_text
  end
  it 'has comments' do
    c = @renderer.comments
    c.length.should == 10
    c.first.is_a?(CommentRenderer).should be_true
    c.first.comment.should == @comment
  end
  describe '#to_html' do
    before do
      @controller = SampleController.new
      @r_opts = {:partial => 'shared/stream_element', :locals => @post_hash}
    end
    it 'benchmarks the partial' do
      time = Benchmark.realtime{
        @controller.render_to_string(@r_opts)
      }
      (time*1000).should < 200
    end
    it 'is correct' do
      v = @controller.render_to_string(@r_opts)
      s = @renderer.to_html
      no_space_v = v.gsub(/\s+/,'')
      no_space_s = s.gsub(/\s+/,'')
      no_space_s.should == no_space_v
    end
    it 'is fast' do
      time = Benchmark.realtime{
        @renderer.to_html
      }
      (time*1000).should < 0
    end
  end
  describe '#reshare_pane' do
    before do
      @controller = SampleController.new
      reshare_hash = {:aspects => @renderer.aspects_without_post(@user.aspects, @post),
        :post => @post}
      @r_opts = {:partial => 'shared/reshare', :locals => reshare_hash}
    end
    it 'benchmarks the partial' do
      time = Benchmark.realtime{
        @controller.render_to_string(@r_opts)
      }
      (time*1000).should < 5
    end
    it 'is correct' do
      v = @controller.render_to_string(@r_opts)
      s = @renderer.reshare_pane
      no_space_v = v.gsub(/\s+/,'')
      no_space_s = s.gsub(/\s+/,'')
      no_space_s.should == no_space_v    
    end
    it 'is fast' do
      time = Benchmark.realtime{
        @renderer.reshare_pane
      }
      (time*1000).should < 1
    end   
  end
  describe '#post_section' do
    before do
      @controller = SampleController.new
      post_hash = {:post => @post,
        :photos => @post.photos}
      @r_opts = {:partial => 'status_messages/status_message', :locals => post_hash}
    end
    it 'benchmarks the partial' do
      time = Benchmark.realtime{
        @controller.render_to_string(@r_opts)
      }
      (time*1000).should < 4
    end
    it 'is correct' do
      v = @controller.render_to_string(@r_opts)
      s = @renderer.post_section
      no_space_v = v.gsub(/\s+/,'')
      no_space_s = s.gsub(/\s+/,'')
      no_space_s.should == no_space_v
    end
    it 'is fast' do
      time = Benchmark.realtime{
        @renderer.post_section
      }
      (time*1000).should < 3
    end 
  end
  describe '#comments_section' do
    before do
      @controller = SampleController.new
      comments_hash = {:comment_hashes => @post_hash[:comments],
        :post_id => @post.id}
      @r_opts = {:partial => 'comments/comments', :locals => comments_hash}
    end
    it 'benchmarks the partial' do
      time = Benchmark.realtime{
        @controller.render_to_string(@r_opts)
      }
      (time*1000).should < 13
    end
    it 'is correct' do
      v = @controller.render_to_string(@r_opts)
      s = @renderer.comments_section
      no_space_v = v.gsub(/\s+/,'')
      no_space_s = s.gsub(/\s+/,'')
      no_space_s.should == no_space_v
    end
    it 'is fast' do
      time = Benchmark.realtime{
        @renderer.comments_section
      }
      (time*1000).should < 3
    end 
  end
  describe '#new_comment_form' do
    before do
      @controller = SampleController.new
      new_comment_hash = {:post_id => @post.id}
      @r_opts = {:partial => 'comments/new_comment', :locals => new_comment_hash}
    end
    it 'benchmarks the partial' do
      time = Benchmark.realtime{
        @controller.render_to_string(@r_opts)
      }
      (time*1000).should < 6
    end
    it 'is correct' do
      v = @controller.render_to_string(@r_opts)
      s = @renderer.new_comment_form
      no_space_v = v.gsub(/\s+/,'')
      no_space_s = s.gsub(/\s+/,'')
      no_space_s.should == no_space_v
    end
    it 'is fast' do
      time = Benchmark.realtime{
        @renderer.new_comment_form
      }
      (time*1000).should < 1
    end 
  end
  class SampleController < ApplicationController
    def url_options
      {:host => ""}
    end
  end
end
