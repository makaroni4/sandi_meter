class TestClass
  def render4
    return '' if @elements.empty?
    @context.content_tag :ol, class: 'breadcrumb' do
      render_collection
    end
  end

  def render5
    return '' if @elements.empty?
    @context.content_tag :ol, class: 'breadcrumb' do
      render_collection
    end
    puts "5th line!"
  end

  def render6
    return '' if @elements.empty?
    @context.content_tag :ol, class: 'breadcrumb' do
      render_collection
    end
    puts "5th line!"
    puts "6th line!"
  end
end
