Pod::Spec.new do |s|
  s.name         = "PSNetWork"
  s.version      = "0.0.1"
  s.summary      = "使用RAC封装AFNetWork"
  s.description  = <<-DESC
                   使用RAC封装AFNetWork
                   DESC

  s.homepage     = "https://github.com/yangmiemie1116/PSNetWork.git"
  s.license      = "MIT"
  s.author             = { "杨志强" => "yangzhiqiang116@gmail.com" }
  s.social_media_url   = "http://www.jianshu.com/u/bd06a732c598"
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/yangmiemie1116/PSNetWork.git", :tag => "#{s.version}" }
  s.source_files  = "PSNetWork/*.{h,m}"
  s.requires_arc = true
  s.dependency "ReactiveObjC", "~> 2.1"
  s.dependency "AFNetworking"

end
