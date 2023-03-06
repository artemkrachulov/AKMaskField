Pod::Spec.new do |s|

	s.name         = "AKMaskField"
  s.version      = "2.0.4"
  s.homepage     = "https://github.com/artemkrachulov/AKMaskField"
  s.summary      = "Enter data in the fixed quantity and in the certain format."
  s.description  = <<-DESC
                   AKMaskField is UITextField subclass which allows enter data in the fixed quantity and in the certain format (credit cards, telephone numbers, dates, etc.). You only need setup mask string and mask template string visible for the user.
                  DESC

  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Artem Krachulov" => "artem.krachulov@gmail.com"  }

  # Source Info

	s.ios.deployment_target = "12.0"

	s.source       	= { 
		:git => "https://github.com/artemkrachulov/AKMaskField.git", 
		:tag => 'v'+s.version.to_s 
	}

 	s.source_files  = "AKMaskField/*.{swift}"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
end