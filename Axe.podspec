Pod::Spec.new do |s|
  s.name                      = "Axe"
  s.version                   = "0.0.2"
  s.summary                   = "Axe is all the reinforcement this army needs"
  s.homepage                  = "https://github.com/axe-org/axe"
  s.license                   = { :type => "MIT"}
  s.author                    = { "luoxianming" => "luoxianmingg@gmail.com" }
  s.ios.deployment_target     = '8.0'
  s.source                    = { :git => "https://github.com/axe-org/axe.git.git", :tag => s.version}
  s.default_subspec           = "Core"
  s.subspec "Core" do |ss|
    ss.source_files           = "Axe/Axe/Axe.h"
    ss.subspec "Router" do |sss|
      sss.source_files        = "Axe/Axe/Router/*.{h,m}","Axe/Axe/AXEDefines.h"
    end
    ss.subspec "Event" do |sss|
      sss.source_files        = "Axe/Axe/Event/*.{h,m}","Axe/Axe/AXEDefines.h"
    end
    ss.subspec "Data" do |sss|
      sss.source_files        = "Axe/Axe/Data/*.{h,m}","Axe/Axe/AXEDefines.h"
    end
  end
  s.subspec "TabBarController" do |ss|
    ss.dependency             "Axe/Core"
    ss.source_files           = "Axe/Extension/TabBarController/*.{h,m}"
  end
  s.subspec "Html" do |ss|
    ss.dependency             "Axe/Util"
    ss.dependency             "Axe/JavascriptSupport"
    ss.dependency             "WebViewJavascriptBridge"
    ss.source_files           = "Axe/Extension/Html/*.{h,m}"
  end
  s.subspec "JavascriptSupport" do |ss|
    ss.dependency             "Axe/Core"
    ss.source_files           = "Axe/Extension/JavascriptSupport/*.{h,m}"
  end
  s.subspec "React" do |ss|
    ss.dependency             "Axe/Util"
    ss.dependency             "Axe/JavascriptSupport"
    ss.dependency             "MXReact/CxxBridge"
    ss.source_files           = "Axe/Extension/React/*.{h,m}"
  end
  s.subspec "OfflineHtml" do |ss|
    ss.dependency             "Axe/Html"
    ss.dependency             "OfflinePackage"
    ss.source_files           = "Axe/Extension/OfflineHtml/*.{h,m}"
  end
  s.subspec "OfflineReact" do |ss|
    ss.dependency             "Axe/React"
    ss.dependency             "OfflinePackage"
    ss.source_files           = "Axe/Extension/OfflineReact/*.{h,m}"
  end
  s.subspec "Util" do |ss|
    ss.dependency             "Axe/Core"
    ss.source_files           = "Axe/Extension/Util/*.{h,m}"
  end
end