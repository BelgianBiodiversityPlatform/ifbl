module ApplicationHelper
  def btt
    content_tag :p, :class => 'btt' do
      r = image_tag 'arrow-090.png' 
      r += link_to 'Back to top', '#page_top'
      r
    end
  end
end
