InstallMethod(
	Origami, [IsPerm, IsPerm], function(horizontal, vertical)
		local d;
		d :=  Maximum(LargestMovedPoint(horizontal), LargestMovedPoint(vertical)) - Minimum(SmallestMovedPoint(horizontal), SmallestMovedPoint(vertical)) + 1;
		if IsTransitive( Group(horizontal, vertical) ) = false
			then Error("The described surface is not connected. The permutation group, generated by the two permutations, must act transitive on [1..d] ");
		fi;
		return OrigamiWithoutTest(horizontal, vertical, d);
	end
	);

InstallOtherMethod( Origami, [IsPerm, IsPerm, IsInt], function(horizontal, vertical, d)
		if IsTransitive( Group(horizontal, vertical) ) = false
			then Error("The described surface is not connected. The permutation group, generated by the two permutations, must act transitive on [1..d] ");
		fi;
		return OrigamiWithoutTest(horizontal, vertical, d);
	end
	);


InstallGlobalFunction(
	OrigamiWithoutTest, function(horizontal, vertical, d)
		local Obj, ori;
		ori:= rec(d := d, x := horizontal, y := vertical);
		Obj:= rec();

		ObjectifyWithAttributes( Obj, NewType(OrigamiFamily, IsOrigami and IsAttributeStoringRep) , HorizontalPerm, ori.x, VerticalPerm, ori.y, DegreeOrigami, d );
		return Obj;
	end
	);


InstallMethod(String, [IsOrigami], function(Origami)
	return Concatenation("Origami(", String(HorizontalPerm(Origami)), ", ", String(VerticalPerm(Origami)), ", ", String(DegreeOrigami(Origami)), ")");
	end
);

InstallMethod( DisplayString, [IsOrigami], function( origami )
	local s;
	s := Concatenation("horizontal permutation = ", String(HorizontalPerm(origami)), "\n", "vertical permutation = ", String(VerticalPerm(origami)), "\n");
	return s;
end);

InstallMethod(ViewString, [IsOrigami], function( origami )
	return String( origami );
end);

InstallMethod(PrintString, [IsOrigami], function( origami )
	return String( origami );
end);

InstallMethod(\=, [IsOrigami, IsOrigami], function(O1, O2)
	return (VerticalPerm(O1) = VerticalPerm(O2)) and (HorizontalPerm(O1) = HorizontalPerm(O2));
	end
);


# This method specifies the hash key for origamis
InstallMethod(SparseIntKey, [IsObject, IsOrigami], function( b , origami )
	local HashForOrigami;
	HashForOrigami := function( origami )
    	return (hashForPermutations( HorizontalPerm(origami) ) + hashForPermutations( VerticalPerm(origami) ));
	end;
	return HashForOrigami;
end);


# determines an random origami of a given degree
# INPUT degree d
# OUTPUT a random origami of degree d
InstallGlobalFunction(ExampleOrigami, function (d)
	local x, y;
	repeat
		x:=PseudoRandom(SymmetricGroup(d));
		y:=PseudoRandom(SymmetricGroup(d));
	until IsTransitive(Group(x,y), [1..d]);
	return Origami(x, y, d);
end);

InstallGlobalFunction(IsConnectedOrigami, function(origami)
	return IsTransitive(Group(HorizontalPerm(origami), VerticalPerm(origami)), [1..DegreeOrigami(origami)]);
end);


#This function calculates the coset Graph of the Veech group of an given Origami O
#INPUT: An origami O
#OUTPUT: The coset Graph as Permutations sigma_S and Sigma_T
#CalcVeechGroupGenerators := function(O)
	#local  sigma, Gen,Rep, HelpCalc, D, M, foundM, W, NewGlList, canonicalOrigamiList, i, j, canonicalM, newReps;
	#Gen:= [];
	#Rep:= [S*S^-1];
	#sigma:=[[],[]];
	#canonicalOrigamiList := [OrigamiNormalForm(O)];
	#HelpCalc := function(GlList)
	#	NewGlList := [];
	#	for W in GlList do

	#		newReps := [W*T,W*S];
	#		for j in [1, 2] do
	#			M := newReps[j];
	#			foundM := false;
	#			canonicalM := OrigamiNormalForm(ActionOfSl(M, O));
	#			for i in [1..Length(Rep)] do
	#				if canonicalOrigamiList[i] = canonicalM then
	#					D := Rep[i];
	#					Add(Gen,  M * D^-1); # D^-1 * M ?
	#					foundM := true;
	#					sigma[j][Position(Rep, W)] := Position(Rep, D);
	#					break;
	#				fi;
	#			od;
	#			if foundM = false then
	#				Add(Rep, M);
	#				Add(canonicalOrigamiList, canonicalM);
	#				Add(NewGlList, M);
	#				sigma[j][Position(Rep, W)] := Position(Rep, M);  # = Length(Rep) -1 ?
	#			fi;
	#		od;
	#	od;
	#	if Length(NewGlList) > 0 then HelpCalc(NewGlList); fi;
	#end;
	#HelpCalc([S*S^-1]);
	#return [ModularSubgroup(PermList(sigma[2]), PermList(sigma[1])), Rep, Gen];
#end;

#This function calculates the coset Graph of the Veech group of an given Origami O
#INPUT: An origami O
#OUTPUT: The coset Graph as Permutations sigma_S and Sigma_T
InstallGlobalFunction(CalcVeechGroup, function(O)
	local  sigma, HelpCalc, D, foundM, W, NewOrigamiPositions, canonicalOrigamiList, i, j, newOrigamis;
	sigma:=[[],[]];
	canonicalOrigamiList := [OrigamiNormalForm(O)];
	HelpCalc := function(GlList)
		NewOrigamiPositions := [];
		for W in GlList do
			newOrigamis := [OrigamiNormalForm( ActionOfT(W) ), OrigamiNormalForm( ActionOfS(W) )];
			for j in [1, 2] do
				foundM := false;
				for i in [1..Length(canonicalOrigamiList)] do
					if canonicalOrigamiList[i] = newOrigamis[j] then
						foundM := true;
						sigma[j][Position(canonicalOrigamiList, W)] := i;
						break;
					fi;
				od;
				if foundM = false then
					Add(canonicalOrigamiList, newOrigamis[j]);
					Add(NewOrigamiPositions, newOrigamis[j]);
					sigma[j][Position(canonicalOrigamiList, W)] := Length(canonicalOrigamiList);  # = Length(Rep) -1 ?
				fi;
			od;
		od;
		if Length(NewOrigamiPositions) > 0 then HelpCalc(NewOrigamiPositions); fi;
	end;
	HelpCalc([OrigamiNormalForm(O)]);
	return [ModularSubgroup(PermList(sigma[2]), PermList(sigma[1]))];
end);


InstallGlobalFunction(CalcVeechGroupWithHashTablesOld, function(O)
	local NewOrigamiList, newOrigamis, sigma, HelpCalc, foundM, W, canonicalOrigamiList, i, j,
	 				counter, HelpO;
	counter := 1;
	sigma:=[[],[]];
	canonicalOrigamiList := [];
	HelpO := CanonicalOrigami(O);
	SetindexOrigami (HelpO, 1);
	#AddHash(canonicalOrigamiList, HelpO,  hashForOrigamis);
	HelpCalc := function(GlList)
		NewOrigamiList := [];
		for W in GlList do
			newOrigamis := [OrigamiNormalForm(ActionOfT(W)), OrigamiNormalForm(ActionOfS(W))];
			for j in [1, 2] do
				 #M = newOrigamis[
				i := ContainHash( canonicalOrigamiList, newOrigamis[j], hashForOrigamis );
				if i = 0 then foundM := false; else foundM := true; fi;
				if foundM then
					sigma[j][indexOrigami(W)] := i;
				fi;
				if foundM = false then
					SetindexOrigami(newOrigamis[j], counter);
					AddHash(canonicalOrigamiList, newOrigamis[j], hashForOrigamis);
					Add(NewOrigamiList, newOrigamis[j]);
					sigma[j][indexOrigami(W)] := counter;
					counter := counter + 1;
				fi;
			od;
		od;
		if Length(NewOrigamiList) > 0 then HelpCalc(NewOrigamiList); fi;
	end;
	HelpCalc([HelpO]);
	return ModularSubgroup(PermList(sigma[2]), PermList(sigma[1]));
end);


InstallGlobalFunction(CalcVeechGroupWithHashTables, function(O)
	local NewOrigamiList, newOrigamis, sigma, HelpCalc, foundM, W, canonicalOrigamiList, i, j,
	 				counter, HelpO;
	counter := 2;
	sigma:=[[],[]];
	canonicalOrigamiList := SparseHashTable();
	HelpO := OrigamiNormalForm(O);
	AddDictionary( canonicalOrigamiList, HelpO, 1 );
	HelpCalc := function(GlList)
		NewOrigamiList := [];
		for W in GlList do
			newOrigamis := [OrigamiNormalForm(ActionOfT(W)), OrigamiNormalForm(ActionOfS(W))];
			for j in [1, 2] do
				i := LookupDictionary(canonicalOrigamiList, newOrigamis[j]);
				if i = fail then foundM := false; else foundM := true; fi;
				if foundM then
					sigma[j][LookupDictionary(canonicalOrigamiList, W) ] := i;
				fi;
				if foundM = false then
					AddDictionary( canonicalOrigamiList, newOrigamis[j], counter  );
					Add(NewOrigamiList, newOrigamis[j]);
					sigma[j][ LookupDictionary(canonicalOrigamiList, W) ] := counter;
					counter := counter + 1;
				fi;
			od;
		od;
		if Length(NewOrigamiList) > 0 then HelpCalc(NewOrigamiList); fi;
	end;
	HelpCalc([HelpO]);
	return ModularSubgroup(PermList(sigma[2]), PermList(sigma[1]));
end);

#InstallGlobalFunction(CalcVeechGroupViaEquivalentTest,  function(O)
#	local  sigma, Gen,Rep, HelpCalc, D, M, foundM, W, NewGlList, OrigamiList, i, j, currentOrigami, newReps;
#	Gen := [];
#	Rep := [S*S^-1];
#	sigma := [[],[]];
#	OrigamiList := [O];
#	HelpCalc := function(GlList)
#		NewGlList := [];
#		for W in GlList do
#			newReps := [W*T,W*S];
#			for j in [1, 2] do
#				M := newReps[j];
#				foundM := false;
#				currentOrigami := ActionOfSpecialLinearGroup(M, O);
#				for i in [1..Length(Rep)] do
#					if EquivalentOrigami(OrigamiList[i], currentOrigami)  then
#						D := Rep[i];
#						Add(Gen,  M * D^-1);
#						foundM := true;
#						sigma[j][Position(Rep, W)] := Position(Rep, D);
#	 					break;
#					fi;
#				od;
#				if foundM = false then
#					Add(Rep, M);
#					Add(OrigamiList, currentOrigami);
#					Add(NewGlList, M);
#					sigma[j][Position(Rep, W)]:=Position(Rep, M);  # = Length(Rep) -1 ?
#				fi;
#			od;
#		od;
#		if Length(NewGlList) > 0 then HelpCalc(NewGlList); fi;
#	end;
#	HelpCalc([S*S^-1]);
#	return [ModularSubgroup(PermList(sigma[2]), PermList(sigma[1])), Rep];
#end);

InstallMethod(Genus, "for a origami", [IsOrigami], function(Origami)
	local s, i, e;
	e := 0;
	s := Stratum(Origami);
	for i in s do
		e := e + i;
	od;
	return ( e + 2 ) / 2;
end);

InstallMethod(VeechGroup, "for a origami", [IsOrigami], function(Origami)
	return CalcVeechGroupWithHashTables(Origami);
end);

InstallMethod(Cosets, "for a origami", [IsOrigami], function(Origami)
	return RightCosetRepresentatives(VeechGroup(Origami));
end);


#This function calculates the Stratum of an given Origami
#INPUT: An Origami O
#OUTPUT: The Stratum of the Origami as List of Integers.
InstallMethod(Stratum,"for a origami", [IsOrigami], function(O)
	local com, Stratum, CycleStructure, current,i, j;
	com:=HorizontalPerm(O)* VerticalPerm(O) * HorizontalPerm(O)^(-1) * VerticalPerm(O)^(-1);
	CycleStructure:= CycleStructurePerm(com);
	Stratum:=[];
	for i in [1..Length(CycleStructure)] do
		if IsBound(CycleStructure[i]) then
			for j in [1..CycleStructure[i]] do
				Add(Stratum, i);
			od;
		fi;
	od;
	return AsSortedList( Stratum);
end);

InstallGlobalFunction(ToRec, function(O)
	return rec( d:= DegreeOrigami(O), x:= HorizontalPerm(O), y:= VerticalPerm(O));
end);


InstallGlobalFunction( KinderzeichnungenFromCuspsOfOrigami, function(O)
	local cycles, kz, index, orbitOrigami;
	kz := [];
	cycles := OrbitsDomain(Group(TAction(VeechGroup(O))), [1..Length(Cosets(O))]);
	for index in [1..Length(cycles)] do
		orbitOrigami := ActionOfSpecialLinearGroup( Cosets ( O ) [ cycles [ index ][ 1 ] ], O);
		Add(kz,  Kinderzeichnung( HorizontalPerm( orbitOrigami ), VerticalPerm( orbitOrigami ) * HorizontalPerm( orbitOrigami ) * VerticalPerm( orbitOrigami )^-1));
	od;
	return List(kz, NormalKZForm);
end);

InstallGlobalFunction( EquivalentOrigami, function(O1, O2)
	if RepresentativeAction(SymmetricGroup(DegreeOrigami(O1)), [HorizontalPerm(O1), VerticalPerm(O1)],
																			[HorizontalPerm(O2), VerticalPerm(O2)], OnTuples) = fail
		 then return false;
	else
		return true;
	fi;
end
);

InstallGlobalFunction(HasVeechGroupSl_2, function(O)
	if EquivalentOrigami( O, ActionOfS(O) ) then
		if EquivalentOrigami( O, ActionOfT(O)) then
			return true;
		fi;
	fi;
	return false;
end
);

InstallMethod(IO_Pickle, "for an origami", [IsFile, IsOrigami], function(f, O)
	IO_AddToPickled(O);
	if IO_Write(f, "ORIG") = fail then IO_FinalizePickled(); return IO_Error; fi;
	if IO_Pickle(f, HorizontalPerm(O)) = IO_Error then IO_FinalizePickled(); return IO_Error; fi;
	if IO_Pickle(f, VerticalPerm(O)) = IO_Error then IO_FinalizePickled(); return IO_Error; fi;
	if IO_Pickle(f, DegreeOrigami(O)) = IO_Error then IO_FinalizePickled(); return IO_Error; fi;

	if HasStratum(O) then
    if IO_Pickle(f, Stratum(O)) = IO_Error then IO_FinalizePickled(); return IO_Error; fi;
  else
    if IO_Pickle(f, fail) = IO_Error then IO_FinalizePickled(); return IO_Error; fi;
  fi;

	if HasGenus(O) then
    if IO_Pickle(f, Genus(O)) = IO_Error then IO_FinalizePickled(); return IO_Error; fi;
  else
    if IO_Pickle(f, fail) = IO_Error then IO_FinalizePickled(); return IO_Error; fi;
  fi;

	if HasVeechGroup(O) then
    if IO_Pickle(f, VeechGroup(O)) = IO_Error then IO_FinalizePickled(); return IO_Error; fi;
  else
    if IO_Pickle(f, fail) = IO_Error then IO_FinalizePickled(); return IO_Error; fi;
  fi;

	IO_FinalizePickled();
  return IO_OK;
end);

IO_Unpicklers.ORIG := function(f)
	local x, y, d, O, stratum, genus, vg;
	x := IO_Unpickle(f);
  if x = IO_Error then return IO_Error; fi;
	y := IO_Unpickle(f);
  if y = IO_Error then return IO_Error; fi;
	d := IO_Unpickle(f);
  if d = IO_Error then return IO_Error; fi;
	O := Origami(x, y, d);
	IO_AddToUnpickled(O);

	stratum := IO_Unpickle(f);
  if stratum = IO_Error then IO_FinalizeUnpickled(); return IO_Error; fi;
	genus := IO_Unpickle(f);
	if genus = IO_Error then IO_FinalizeUnpickled(); return IO_Error; fi;
	vg := IO_Unpickle(f);
	if vg = IO_Error then IO_FinalizeUnpickled(); return IO_Error; fi;

	if stratum <> fail then SetStratum(O, stratum); fi;
	if genus <> fail then SetGenus(O, genus); fi;
	if vg <> fail then SetVeechGroup(O, vg); fi;

	IO_FinalizeUnpickled();
	return O;
end;