Pod::Spec.new do |s|

	s.name         = "TMaskField"
  s.version      = "3.0.0"
  s.homepage     = "https://github.com/Togishiro/TMaskField"
  s.summary      = "Enter data in the fixed quantity and in the certain format."
  s.description  = <<-DESC
                   TMaskField is UITextField subclass which allows enter data in the fixed quantity and in the certain format (credit cards, telephone numbers, dates, etc.). You only need setup mask string and mask template string visible for the user.
                  DESC

  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Rogov Dmitriy" => "rogov_dmitriy@rambler.ru"  }

  # Source Info

	s.ios.deployment_target = "9.0"

	s.source       	= { 
		:git => "https://github.com/Togishiro/TMaskField.git", 
		:tag => 'v'+s.version.to_s 
  }
  s.swift_version     = '5.2'

 	s.source_files  = "TMaskField/*.{swift}"
end