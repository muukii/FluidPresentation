Pod::Spec.new do |s|
  s.name = "FluidPresentation"
  s.version = "0.1.0"
  s.summary = "Presentation-based view controller which can unwind by any gestures."

  s.homepage = "https://github.com/muukii/FluidPresentation"
  s.license = "MIT"
  s.author = "muukii"
  s.source = { :git => "https://github.com/muukii/FluidPresentation.git", :tag => s.version }

  s.swift_version = "5.3"
  s.module_name = s.name
  s.requires_arc = true
  s.ios.deployment_target = "12.0"
  s.ios.frameworks = ["UIKit"]
  s.source_files = "FluidPresentation/**/*.swift"
end
