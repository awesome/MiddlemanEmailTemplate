compass_config do |config|
  config.output_style = :compressed
  config.line_comments = false
end

set :css_dir, 'stylesheets'
set :images_dir, 'images'
#set :build_dir, 'B:/SetDirectory'
set :is_building, false
set :et_content_dir, "Content\\"

configure :build do
  activate :minify_css
  activate :relative_assets
  set :is_building, true
end

module PreMailer
  class << self
    def registered(app)
      require "premailer"
      app.after_build do |builder|
        prefix = build_dir + File::SEPARATOR
        Dir.chdir(build_dir) do
          Dir.glob('**/*.html') do |file|
            premailer = Premailer.new(file, :adapter => :nokogiri, :preserve_styles => false, :remove_comments => true, :remove_ids => true)
            fileout = File.open(file, "w")
            fileout.puts premailer.to_inline_css
            fileout.close
            builder.say_status :premailer, prefix+file
          end
        end
      end
    end
    alias :included :registered
  end
end
::Middleman::Extensions.register(:inline_premailer, PreMailer)
activate :inline_premailer

helpers do
  set :contentAreaCounter, 0
  def content_area(area)
    set :contentAreaCounter, contentAreaCounter + 1
    concat is_building == true ? '<custom type="content" name="contentarea' + contentAreaCounter.to_s + '">' : partial("content/" + area)
  end
  def page_data(ns, var)
    concat is_building == true ? "%%=v(@" + ns + "_" + var + ")=%%" : data.template[ns][var]
  end
  def page_link(ns, var)
    concat is_building == true ? "%%=redirectto(@" + ns + "_" + var + ")=%%" : data.template[ns][var]
  end
end