Pod::Spec.new do |spec|
  spec.name         = "libev"
  spec.version      = "4.3.3"
  spec.summary      = "libev is a high-performance event loop/event model with lots of features."
  spec.homepage     = "http://libev.schmorp.de"
  spec.license      = "libev"
  spec.author       = { "Sunnyyoung" => "iSunnyyoung@gmail.com" }
  spec.source       = { :git => "https://github.com/Sunnyyoung/libev.git", :tag => "#{spec.version}" }

  spec.ios.deployment_target = "8.0"
  spec.osx.deployment_target = "10.10"
  spec.watchos.deployment_target = "2.0"
  spec.tvos.deployment_target = "8.0"

  spec.vendored_frameworks = "Clibev.xcframework"
end
