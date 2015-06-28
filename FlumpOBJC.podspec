Pod::Spec.new do |s|
  s.name             = "FlumpOBJC"
  s.version          = "1.2"
  s.summary  	     = "Flump runtimes for both UIKit and Sparrow Framework."
  s.homepage 		 = "https://github.com/levieggert/FlumpOBJC"
  s.license          = 'MIT'
  s.author           = { "levieggert" => "levi_eggert@hotmail.com" }
  s.platform     	 = :ios, '7.0'
  s.source 			 = { :git => "", :tag => "1.2", :submodules => true }
  s.requires_arc 	 = true

  s.subspec 'export' do |ss|
	
    ss.source_files = 'FlumpExample/Classes/flump/export/*.{h,m}'
  end

  s.subspec 'sparrow' do |ss|
	
	ss.dependency 'Sparrow'
	ss.dependency 'FlumpOBJC/export'
	
    ss.source_files = 'FlumpExample/Classes/flump/sparrow/*.{h,m}'
  end

  s.subspec 'uikit' do |ss|

	ss.dependency 'FlumpOBJC/export'

    ss.source_files = 'FlumpExample/Classes/flump/uikit/*.{h,m}'
  end
end