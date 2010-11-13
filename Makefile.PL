use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	'NAME'            => "Debug::ShowStuff",
	'VERSION_FROM'    => "ShowStuff.pm", # finds $VERSION
	'PREREQ_PM'       => {
		'Tie::IxHash' => 1.1,
		'Taint' => 0.09,
		'MemHandle' => 0.06,
	}, # e.g., Module::Name => 1.1
	
	# Add these new keywords supported since 5.005
	(
		$] >= 5.005 ?
			(
				ABSTRACT_FROM  => "ShowStuff.pm", # retrieve abstract from module
				AUTHOR         => "Miko O'Sullivan <miko\@idocs.com>"
			) :
			
			()
	),
);
