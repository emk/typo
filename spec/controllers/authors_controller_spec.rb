require File.dirname(__FILE__) + '/../spec_helper'

describe AuthorsController, "/index" do
  before(:each) do
    User.stub!(:find_all_with_article_counters) \
      .and_return(mock('authors', :null_object => true))

    controller.stub!(:template_exists?) \
      .and_return(true)

    this_blog = Blog.default
    controller.stub!(:this_blog) \
      .and_return(this_blog)
  end

  def do_get
    get 'index'
  end

  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render :index" do
    do_get
    response.should render_template(:index)
  end

  it "should fall back to articles/groupings" do
    controller.should_receive(:template_exists?) \
      .with() \
      .and_return(false)
    do_get
    response.should render_template('articles/groupings')
  end
end

describe AuthorsController, '/articles/category/foo' do
  before(:each) do
    @author = mock('author', :null_object => true)
    @author.stub!(:empty?) \
      .and_return(false)

    User.stub!(:find_by_permalink) \
      .and_return(@author)

    controller.stub!(:template_exists?) \
      .and_return(true)
    this_blog = Blog.default
    controller.stub!(:this_blog) \
      .and_return(this_blog)
  end

  def do_get
    get 'show', :id => 'foo'
  end

  it 'should be successful' do
    do_get()
    response.should be_success
  end

  it 'should call User.find_by_permalink' do
    User.should_receive(:find_by_permalink) \
      .with('foo') \
      .and_return(mock('author', :null_object => true))
    do_get
  end

  it 'should render :show by default' do
    do_get
    response.should render_template(:show)
  end

  it 'should fall back to rendering articles/index' do
    controller.should_receive(:template_exists?) \
      .with() \
      .and_return(false)
    do_get
    response.should render_template('articles/index')
  end

  it 'should set the page title to "Author foo"' do
    do_get
    assigns[:page_title].should == 'Author foo, everything about foo'
  end

  it 'should render an error when the author has no articles' do
    @author.should_receive(:articles) \
      .and_return([])

    do_get

    response.should render_template('articles/error')
    assigns[:message].should == "Can't find any articles for 'foo'"
  end

  it 'should render the atom feed for /articles/author/foo.atom' do
    get 'show', :id => 'foo', :format => 'atom'
    response.should render_template('articles/_atom_feed')
  end

  it 'should render the rss feed for /articles/author/foo.rss' do
    get 'show', :id => 'foo', :format => 'rss'
    response.should render_template('articles/_rss20_feed')
  end
end
