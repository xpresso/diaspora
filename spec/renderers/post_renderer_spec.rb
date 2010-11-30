require 'spec_helper'
describe PostRenderer do
  before do
    @user = make_user
    @aspect = @user.aspects.create(:name => 'strangers')
    @post = @user.post :status_message, :message => 'hello', :to => @aspect.id
    @comment = @user.comment 'anyone there?', :on => @post
    @post_hash = {:current_user => @user,
      :post => @post,
      :photos => @post.photos,
      :aspects => @user.aspects,
      :comments => [{:comment => @comment, 
                     :person => @user.person}],
      :person => @user.person}
    @renderer = PostRenderer.new(@post_hash)
  end
  it 'has a post' do
    @renderer.post.should == @post
  end
  it 'has a person' do
    @renderer.person.should == @user.person
  end
  it 'has comments' do
    c = @renderer.comments
    c.length.should == 1
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
      v.gsub!(/^s+/,'').should == @renderer.to_html.gsub!(/^s+/,'')
    end
    it 'is fast' do
      time = Benchmark.realtime{
        @renderer.to_html
      }
      (time*1000).should < 20
    end
  end
  class SampleController < ApplicationController
    def url_options
      {:host => ""}
    end
  end
end
