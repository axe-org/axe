Pod::Spec.new do |s|
  s.name                      = "Axe"
  s.version                   = "0.0.1"
  s.summary                   = "Axe is all the reinforcement this army needs"
  s.homepage                  = "https://github.com/CodingForMoney/Axe"
  s.license                   = { :type => "MIT"}
  s.author                    = { "luoxianming" => "luoxianmingg@gmail.com" }
  s.ios.deployment_target     = '8.0'
  s.source                    = { :git => "https://github.com/CodingForMoney/Axe.git", :tag => s.version}
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
end