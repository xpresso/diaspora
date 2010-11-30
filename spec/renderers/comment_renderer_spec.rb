require 'spec_helper'
describe CommentRenderer do
  before do
    @user = make_user
    @aspect = @user.aspects.create(:name => 'strangers')
    @post = @user.post :status_message, :message => 'hello', :to => @aspect.id
    @comment = @user.comment 'anyone there?', :on => @post
    @renderer = CommentRenderer.new(:comment => @comment, :person => @user.person)
  end
  it 'has a comment' do
    @renderer.comment.should == @comment
  end
  it 'has a person' do
    @renderer.person.should == @user.person
  end
  describe '#to_html' do
    before do
      @controller = SampleController.new
      @r_opts = {:partial => 'comments/comment', :locals => {:hash => {:comment => @comment, :person => @comment.person}}}
    end
    it 'benchmarks the partial' do
      time = Benchmark.realtime{
        @controller.render_to_string(@r_opts)
      }
      (time*1000).should < 12
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
      (time*1000).should < 2
    end
  end
  class SampleController < ApplicationController
    def url_options
      {:host => ""}
    end
  end
end
