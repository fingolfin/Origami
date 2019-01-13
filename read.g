ReadPackage("Origami/lib/origami.gi");
ReadPackage("Origami/lib/action.gi");
ReadPackage("Origami/lib/canonical.gi");
ReadPackage("Origami/lib/hash.gi");
ReadPackage("Origami/lib/origami-list.gi");
ReadPackage("Origami/lib/kinderzeichnungen.gi");

if (TestPackageAvailability( "HomalgToCAS" ,"2018.06.15") <> fail) and (TestPackageAvailability( "IO_ForHomalg", "2017.09.02") <> fail ) and  ( TestPackageAvailability( "IO", "4.5.1") <> fail ) and 		( TestPackageAvailability ("RingsForHomalg", "2018.04.04" <> fail ) )
	
	then ReadPackage("Origami/lib/sagefunction.gi");
fi;