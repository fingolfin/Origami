##### CONSTRUCTORS

InstallMethod(Origami, [IsPerm, IsPerm], function(sigma_x, sigma_y)
	local d;
	d := Maximum(LargestMovedPoint(sigma_x), LargestMovedPoint(sigma_y), 1);
	if not IsTransitive(Group(sigma_x, sigma_y), [1..d]) then
		Error("The described surface is not connected. The permutation group that is generated by the two permutations must act transitively on {1,...,d}.");
	fi;
	return OrigamiNC(sigma_x, sigma_y, d);
end);

InstallOtherMethod(Origami, [IsPerm, IsPerm, IsPosInt], function(sigma_x, sigma_y, d)
	if not IsTransitive(Group(sigma_x, sigma_y), [1..d]) then
		Error("The described surface is not connected. The permutation group that is generated by the two permutations must act transitively on {1,...,d}.");
	fi;
	return OrigamiNC(sigma_x, sigma_y, d);
end);

InstallMethod(OrigamiNC, [IsPerm, IsPerm], function(sigma_x, sigma_y)
	local d;
	d := Maximum(LargestMovedPoint(sigma_x), LargestMovedPoint(sigma_y), 1);
	return OrigamiNC(sigma_x, sigma_y, d);
end);

InstallOtherMethod(OrigamiNC, [IsPerm, IsPerm, IsPosInt], function(sigma_x, sigma_y, d)
	local Obj, ori;
	ori:= rec(d := d, x := sigma_x, y := sigma_y);
	Obj:= rec();

	ObjectifyWithAttributes( Obj, NewType(OrigamiFamily, IsOrigami and IsAttributeStoringRep) , HorizontalPerm, ori.x, VerticalPerm, ori.y, DegreeOrigami, d );
	return Obj;
end);

#####




##### IMPLEMENTATIONS OF 'String', 'Display', '=', ETC. FOR ORIGAMIS

InstallMethod(String, [IsOrigami], function(O)
	return Concatenation("Origami(", String(HorizontalPerm(O)), ", ", String(VerticalPerm(O)), ", ", String(DegreeOrigami(O)), ")");
end);

InstallMethod(DisplayString, [IsOrigami], function(O)
	local s;
	s := Concatenation("Origami of degree ", String(DegreeOrigami(O)), "\n", "Horizontal permutation : ", String(HorizontalPerm(O)), "\n", "Vertical permutation : ", String(VerticalPerm(O)), "\n");
	if HasGenus(O) then
		s := Concatenation(s, "Genus : ", String(Genus(O)), "\n");
	fi;
	if HasStratum() then
		s := Concatenation(s, "Stratum : ", String(Stratum(O)), "\n");
	fi;
	return s;
end);

InstallMethod(ViewString, [IsOrigami], function(O)
	return String(O);
end);

InstallMethod(PrintString, [IsOrigami], function(O)
	return String(O);
end);

InstallMethod(\=, [IsOrigami, IsOrigami], function(O1, O2)
	return (HorizontalPerm(O1) = HorizontalPerm(O2)) and (VerticalPerm(O1) = VerticalPerm(O2));
end);

InstallMethod(\<, [IsOrigami, IsOrigami], function(O1, O2)
	return [HorizontalPerm(O1), VerticalPerm(O1)] < [HorizontalPerm(O2), VerticalPerm(O2)];
end);

InstallMethod(SparseIntKey, [IsObject, IsOrigami], function(origami_collection, origami)
	return function(O)
    	return (HashForPermutations(HorizontalPerm(O)) + HashForPermutations(HorizontalPerm(O)));
	end;
end);

#####




##### CONSTRUCTORS FOR CERTAIN CLASSES OF ORIGAMIS

InstallGlobalFunction(XOrigami, function(d)
	# TODO: implement this
	Error("Not yet implemented.");
end);

InstallGlobalFunction(ElevatorOrigami, function(length, height, steps)
	local sigma_h, sigma_h_step, sigma_v, sigma_v_step, step;

	sigma_h := ();
	sigma_h_step := [];
	for step in [1 .. steps] do
		sigma_h_step[step] := CycleFromList([(step-1)*(length+height)+1 .. (step-1)*(length+height)+length]);
		sigma_h := sigma_h * sigma_h_step[step];
	od;

	sigma_v := ();
	sigma_v_step := [];
	for step in [1 .. steps-1] do
		sigma_v_step[step] := CycleFromList([step*length+(step-1)*height .. step*(length+height)+1]);
		sigma_v := sigma_v * sigma_v_step[step];
	od;
	sigma_v_step := [steps*length+(steps-1)*height .. steps*(length+height)];
	Add(sigma_v_step, 1); #connecting the last tile of the last step to the first tile of the first step

	sigma_v := sigma_v * CycleFromList(sigma_v_step);

	return OrigamiNormalForm(Origami(sigma_h, sigma_v));
end);

InstallGlobalFunction(StaircaseOrigami, function(length, height, steps)
	local sigma_h, sigma_h_step, sigma_v, sigma_v_step, step;
	sigma_h := ();
	sigma_h_step := [];
	for step in [1 .. steps] do
		sigma_h_step[step] := CycleFromList([(step-1)*(length+height)+1 .. (step-1)*(length+height)+length]);
		sigma_h := sigma_h * sigma_h_step[step];
	od;

	sigma_v := ();
	sigma_v_step := [];
	for step in [1 .. steps-1] do
		sigma_v_step[step] := CycleFromList([step*length+(step-1)*height .. step*(length+height)+1]);
		sigma_v := sigma_v * sigma_v_step[step];
	od;

	sigma_v := sigma_v * CycleFromList([steps*length+(steps-1)*height .. steps*(length+height)]);	#Loop one shorter because the last cycle is one shorter.

	return OrigamiNormalForm(Origami(sigma_h, sigma_v));
end);

InstallGlobalFunction(QuasiRegularOrigami, function(G,H,r,u)
  local N, tiles, i, j, list_h, sigma_v, sigma_h, list_v;

	# check whether G is generated by r and u
  if not G = Group(r,u) then
		Error("The elements r and u do not generate the group G.");
  fi;
	# check whether H is a subgroup of G
  if not IsSubgroup(G,H) then
		Error("H is not a Subgroup of G");
  fi;
	# check whether H contains any non-trivial normal subgroups of G
  if ContainsNormalSubgroups(G, H) then
  	Error("Faulty subgroup. H contains non-trivial normal subgroups of G.");
  fi;


	tiles := RightCosets(G, H);
	list_v := [];
	list_h := [];
	i := 1;
	sigma_h := ();
	sigma_v := ();

	while i <= Length(tiles) do
		j := 1;
		list_h := [];
		list_h[1] := i;

		# check whether the element is already in one of the cycles
		if not i in MovedPoints(sigma_h) then
			while Position(tiles, tiles[i]*r^j) <> i do
				list_h[j+1] := Position(tiles, tiles[i]*r^j);
    		j := j+1;
  		od;

      # check whether the cycles are disjoint
  		if Intersection(MovedPoints(sigma_h), MovedPoints(CycleFromList(list_h))) = [] then
				sigma_h := sigma_h * CycleFromList(list_h);
			fi;
		fi;

  	j := 1;
  	list_v := [];
  	list_v[1] := i;

		# check whether the element is already in one of the cycles
 		if not i in MovedPoints(sigma_v) then
  		while Position(tiles, tiles[i] * u^j) <> i do
				list_v[j+1] := Position(tiles, tiles[i] * u^j);
    		j := j+1;
			od;

			# check whether the cycles are disjoint
   		if Intersection(MovedPoints(sigma_v), MovedPoints(CycleFromList(list_v))) = [] then
				sigma_v := sigma_v * CycleFromList(list_v);
			fi;
		fi;

		i := i+1;
	od;
	return OrigamiNormalForm(Origami(sigma_h, sigma_v));
end);

InstallGlobalFunction(ContainsNormalSubgroups, function(G, H)
  local N, i;

	N:= NormalSubgroups(G);
	N:=Filtered(N, i->Size(i)<=Size(H));

  if not IsSubgroup(G,H) then
		Error("H is not a subgroup of G.");
	fi;

	if IsTrivial(H) then return false; # we only look for non-trivial normal subgroups
  elif IsNormal(G, H) then return true;
  else return Length(Filtered(N, K -> IsSubgroup(H, K))) <> 1;
  fi;
end);

InstallGlobalFunction(QROFromGroup, function(G)
  local subgroups, j,i,m, origami_list, r, u, F2, f2_epis;

	if Length(SmallGeneratingSet(G)) > 2 then
		if Length(GQuotients(FreeGroup(2), G)) = 0 then
			Error("The group <G> is not two-generated.");
			return;
		fi;
	fi;

	F2 := FreeGroup(2);
	f2_epis := GQuotients(F2, G);
	r:=[]; u:=[];

	for i in [1.. Length(f2_epis)] do
		r[i] := Image(f2_epis[i], F2.1);
	 	u[i] := Image(f2_epis[i], F2.2);
	od;

	subgroups := AllSubgroups(G);
	subgroups := Filtered(subgroups, i -> not ContainsNormalSubgroups(G,i));

	m := 1;
	origami_list := [];
	for j in [1..Length(f2_epis)] do
	  for i in subgroups do
	  	origami_list[m]   := QuasiRegularOrigami(G,i, r[j], u[j]);
	  	origami_list[m+1] := QuasiRegularOrigami(G, i, u[j], r[j]);
	  	m := m+2;
	  od;
	od;
	origami_list := DuplicateFreeList(origami_list);
  return origami_list;
end);

InstallGlobalFunction(QROFromOrder, function(d)
  local i, origami_list, group_list;

  group_list := Filtered(AllSmallGroups(d), function(G)
		if Length(SmallGeneratingSet(G)) <= 2 then return true; fi;
		return Length(GQuotients(FreeGroup(2), G)) >= 1;
	end);
  origami_list := [];

  for i in [1..Length(group_list)] do
  	Append(origami_list, QROFromGroup(group_list[i]));
  od;

  return origami_list;
end);

InstallGlobalFunction(DefinesQuasiRegularOrigami, function(G, U, r, u)
	local N;
	N := Normalizer(G, U);
	return IsNormal(G, N) and IsAbelian(G/N);
end);

InstallGlobalFunction(RandomOrigami, function(d)
	local sigma_x, sigma_y, S_d;
	S_d := SymmetricGroup(d);
	sigma_x := Random(GlobalMersenneTwister, S_d);
	sigma_y := Random(GlobalMersenneTwister, S_d);
	while not IsTransitive(Group(sigma_x, sigma_y), [1..d]) do
		sigma_y := Random(GlobalMersenneTwister, S_d);
	od;
	return OrigamiNC(sigma_x, sigma_y, d);
end);

InstallGlobalFunction(CylinderStructure, function(O)
	local list, i, m, cycles, helpcycle, cycleLength, sigma_h, sigma_v, diff, mat, mat_inv;
	sigma_h := HorizontalPerm(O);
	sigma_v := VerticalPerm(O);
	if sigma_h=() then
		list := [];
	else
		cycles := Cycles(sigma_h, [1..DegreeOrigami(O)]);
		#s is list of the cycles in the horizontal permutation of the origami
		list := [];
		cycleLength := List(cycles, i->(Length(i))); #Length of the cycles in the permutation
		for m in [1..Maximum(cycleLength)] do
			helpcycle := Filtered(cycles, i->Length(i)=m); #Zykel der Länge m
			helpcycle := AsSet(helpcycle);
			while helpcycle <> []  do
				mat := [];
				mat_inv := [];
				for i in [1..Length(helpcycle[1])] do #calcutlatin the orbit under sigma_h and sigma_h^{-1} of each tile in the cycle
					mat[i] := Orbit(Group(sigma_v), helpcycle[1][i]);
					mat_inv[i] := Orbit(Group(Inverse(sigma_v)), helpcycle[1][i]);
				od;
				diff := Intersection(helpcycle, Union(TransposedMat(mat),TransposedMat(mat_inv))); #transposing the matrix to check on whether there are cylinders lying over each other
				Add(list, [Length(diff), m]); #diff contains the cycles of same lenght which form a cylinder
				helpcycle := Difference(helpcycle, diff);
			od;
		od;
	fi;
	return list;
end);

InstallMethod(SumOfLyapunovExponents, [IsOrigami], function(O)
  local stratum, orbit,i,j, sum;
	sum := 0;
	if not Stratum(O)=[] then
		if IsNormalOrigami(O) then
			sum := SumOfLyapunovExponents(AsNormalStoredOrigami(O));
		else
  		orbit := VeechGroupAndOrbit(O).orbit;
			if Length(orbit) > 1 then
				for i in [1.. Length(orbit)] do
  				for j in [1.. Length(CylinderStructure(orbit[i]))] do
    			sum := sum + CylinderStructure(orbit[i])[j][1]/CylinderStructure(orbit[i])[j][2]; #height/width of the cylinders of the orbit
  				od;
				od;
				sum := sum/Length(orbit);
			fi;
  		stratum := Stratum(O);
  		for i in [1..Length(stratum)] do
    		sum := sum + (1/12)*(stratum[i])*(stratum[i]+2)/(stratum[i]+1);
			od;
		fi;
	fi;
	return sum;
end);

InstallOtherMethod(SumOfLyapunovExponents, [IsNormalStoredOrigami], function(O)
	local  sum, stratum_data, orbit,i;
	sum := 0;
	if Stratum(O) <> [] then
		O := AsPermutationRepresentation(O);
		orbit := VeechGroupAndOrbit(O).orbit;

		#sum over the orbit (n/#orb)sum_{orb}{1/(ord(x)^2)}
		for i in [1..Length(orbit)] do
			sum := sum +(1/Order(HorizontalPerm(orbit[i]))^2);
		od;
		sum := sum*(DegreeOrigami(O)/Length(orbit));

		# 1/12*k*a(a+2)/(a+1)
		stratum_data := [Stratum(O)[1], Length(Stratum(O))];
		sum := sum + (1/12)*stratum_data[2]*( stratum_data[1])*(stratum_data[1]+2)/(stratum_data[1]+1);
	fi;
	return sum;
end);

InstallGlobalFunction(NormalformConjugators, [IsOrigami],function(origami)
	local n, i, j, L, Q, seen, numSeen, v, wx, wy, G, minimalCycleLengths,
				minimizeCycleLengths, cycleLengths, m, l, x, y;
	x := HorizontalPerm(origami);
	y := VerticalPerm(origami);
	n := Maximum(LargestMovedPoint([x,y]), 1);

	# Find points which minimize the lengths of the cycles in which they occur.
	# In most cases, this greatly reduces the number of breadths-first searches below.

	G := [];

	# Starting from each of the vertices found above, do a breadth-first search
	# and list the vertices in the order they appear.
	# This defines a permutation l with which we conjugate x and y.
	# From the resulting list of pairs of permutations (all of which are by
	# definition simultaneously conjugated to (x,y)) we choose the lexicographically
	# smallest one as the canonical form.
	for i in [1..n] do
		L := ListWithIdenticalEntries(n, 0);
		seen := ListWithIdenticalEntries(n, false);
		Q := [i];
		seen[i] := true;
		numSeen := 1;
		L[i] := 1;
		while numSeen < n do
			v := Remove(Q, 1);
			wx := v^x;
			wy := v^y;
			if not seen[wx] then
				Add(Q, wx);
				seen[wx] := true;
				numSeen := numSeen + 1;
				L[wx] := numSeen;
			fi;
			if not seen[wy] then
				Add(Q, wy);
				seen[wy] := true;
				numSeen := numSeen + 1;
				L[wy] := numSeen;
			fi;
		od;
		Add(G, L);
	od;

	Apply(G, PermList);
	return G;
end);

InstallGlobalFunction(ConjugatorsToInverse, [IsOrigami],	function(origami)
local origami_1, G, G_1, veechgroupmatr,O,O_1, list,i,j;
	veechgroupmatr:=VeechGroup(origami);
	if not IsElementOf([[-1,0],[0,-1]],veechgroupmatr) #testing if -1 is in the VeechGroup
			then Error("VeechGroup must contain -1");
	fi;
	origami_1:=Origami(Inverse(HorizontalPerm(origami)), Inverse(VerticalPerm(origami))); #-1.O
	G:=NormalformConjugators(origami); #permutations to a normalform. for each of the tiles one
	G_1:=NormalformConjugators(origami_1);
	O:=List(G,i->Origami(i^-1*HorizontalPerm(origami)*i, i^-1*VerticalPerm(origami)*i)); #origamis derived from the permutations above
	O_1:=List(G_1,i->Origami(i^-1*HorizontalPerm(origami_1)*i, i^-1*VerticalPerm(origami_1)*i));#we need to calculate these to test find k s.t. sigma_i *origami *sigma_i^-1=delta_k(i)*origami_1*delta_k(i)^-1
	#fitting the permuations together
	list:=[];
	#calculating now
	for i in [1 .. Length(O)] do
	list[i]:=[G[i], G_1[Position(O_1,O[i])]];
	list[i]:=list[i][1]*Inverse(list[i][2]);
	od;
	return DuplicateFreeList(list);
end);
#####




##### METHODS FOR VEECH GROUP CALCULATION

InstallMethod(ComputeVeechGroup, [IsOrigami], function(O)
	local  sigma, ExpandTree, is_new, P, new_origami_list, canonical_origami_list, i, j, new_origamis;

	sigma := [[],[]];
	canonical_origami_list := [OrigamiNormalForm(O)];

	ExpandTree := function(new_leaves)
		new_origami_list := [];
		for P in new_leaves do
			new_origamis := [OrigamiNormalForm(ActionOfS(P)), OrigamiNormalForm(ActionOfT(P))];
			for j in [1, 2] do
				is_new := true;
				for i in [1..Length(canonical_origami_list)] do
					if canonical_origami_list[i] = new_origamis[j] then
						is_new := false;
						sigma[j][Position(canonical_origami_list, P)] := i;
						break;
					fi;
				od;
				if is_new then
					Add(canonical_origami_list, new_origamis[j]);
					Add(new_origami_list, new_origamis[j]);
					sigma[j][Position(canonical_origami_list, P)] := Length(canonical_origami_list);
				fi;
			od;
		od;
		if Length(new_origami_list) > 0 then ExpandTree(new_origami_list); fi;
	end;

	ExpandTree([OrigamiNormalForm(O)]);

	return ModularSubgroup(PermList(sigma[1]), PermList(sigma[2]));
end);

InstallMethod(ComputeVeechGroupWithHashTables, [IsOrigami], function(O)
	local sigma, ExpandTree, canonical_origami_list, counter;

	counter := 1;
	sigma := [[],[]];
	O := OrigamiNormalForm(O);
	canonical_origami_list := [];
	AddHash(canonical_origami_list, O, HashForOrigamis);
	Set_IndexOrigami(O, 1);

	ExpandTree := function(new_leaves)
		local new_origami_list, new_origamis, i, j, P;
		new_origami_list := [];
		for P in new_leaves do
			new_origamis := [OrigamiNormalForm(ActionOfS(P)), OrigamiNormalForm(ActionOfT(P))];
			for j in [1, 2] do
				i := ContainsHash(canonical_origami_list, new_origamis[j], HashForOrigamis);
				if i = 0 then
					counter := counter + 1;
					Set_IndexOrigami(new_origamis[j], counter);
					AddHash(canonical_origami_list, new_origamis[j], HashForOrigamis);
					Add(new_origami_list, new_origamis[j]);
					sigma[j][_IndexOrigami(P)] := counter;
				else
					sigma[j][_IndexOrigami(P)] := i;
				fi;
			od;
		od;
		if Length(new_origami_list) > 0 then ExpandTree(new_origami_list); fi;
	end;

	ExpandTree([O]);

	return ModularSubgroup(PermList(sigma[1]), PermList(sigma[2]));
end);

InstallMethod(VeechGroupAndOrbit, [IsOrigami], function(O)
	local new_origami_list, new_origamis, sigma, ExpandTree, P, canonical_origami_list, i, j,
	 				counter, orbit, F, S, T, matrix_list, current_branch;

	O := OrigamiNormalForm(O);
	F := FreeGroup("S", "T");
	S := GeneratorsOfGroup(F)[1];
	T := GeneratorsOfGroup(F)[2];
	counter := 2;
	sigma := [[],[]];
	canonical_origami_list := [];
	AddHash(canonical_origami_list, O, HashForOrigamis);
	Set_IndexOrigami(O, 1);
	if OrigamisEquivalent(ActionOfS(O), O) then
		sigma[2][1] := 1;
	fi;
	if OrigamisEquivalent(ActionOfT(O), O) then
		sigma[1][1] := 1;
	fi;

	orbit := [O];
	matrix_list := [One(F)];

	ExpandTree := function(new_leaves)
		new_origami_list := [];
		for P in new_leaves do
			current_branch := [matrix_list[_IndexOrigami(P)] * S, matrix_list[_IndexOrigami(P)] * T];
			new_origamis := [OrigamiNormalForm(ActionOfS(P)), OrigamiNormalForm(ActionOfT(P))];
			for j in [1, 2] do
				i := ContainsHash(canonical_origami_list, new_origamis[j], HashForOrigamis);
				if i = 0 then
					Set_IndexOrigami(new_origamis[j], counter);
					AddHash(canonical_origami_list, new_origamis[j], HashForOrigamis);
					Add(orbit, new_origamis[j]);
					Add(matrix_list, current_branch[j]);
					Add(new_origami_list, new_origamis[j]);
					sigma[j][_IndexOrigami(P)] := counter;
					counter := counter + 1;
				else
					sigma[j][_IndexOrigami(P)] := i;
				fi;
			od;
		od;
		if Length(new_origami_list) > 0 then
			ExpandTree(new_origami_list);
		fi;
	end;

	ExpandTree([O]);

	return rec(
		veech_group := ModularSubgroup(PermList(sigma[1]), PermList(sigma[2])),
		orbit := orbit,
		matrices := List(matrix_list, w -> MappedWord(w, [S, T], [[[0,-1],[1,0]], [[1,1],[0,1]]]))
	);
end);

InstallMethod(VeechGroup, [IsOrigami], function(O)
	return ComputeVeechGroupWithHashTables(O);
end);
#####




##### GENERAL ATTRIBUTES

InstallMethod(Genus, "for an origami", [IsOrigami], function(O)
	local s, i, e;
	s := Stratum(O);
	e := Sum(s);
	return ( e + 2 ) / 2;
end);

InstallMethod(IndexOfMonodromyGroup, "for an origami", [IsOrigami], function(O)
	return IndexNC(SymmetricGroup(DegreeOrigami(O)), Group(HorizontalPerm(O), VerticalPerm(O)));
end);

InstallMethod(Stratum, "for an origami", [IsOrigami], function(O)
	local commutator, stratum, cycleStructure, i, j;

	commutator := HorizontalPerm(O) * VerticalPerm(O) * HorizontalPerm(O)^(-1) * VerticalPerm(O)^(-1);
	# The commutator of sigma_x and sigma_y corresponds to a walk on the squares of the origami
	# in the directions right, down, left, up. If a square i is not fixed by the commutator,
	# i.e. if after the walk we do not arrive back at i, there is a singularity at
	# the lower right corner of the square i. The degree of the singularity is given
	# as the number of such walks we have to do to get back to i minus 1.
	cycleStructure := CycleStructurePerm(commutator);
	stratum := [];
	for i in [1..Length(cycleStructure)] do
		if IsBound(cycleStructure[i]) then
			for j in [1..cycleStructure[i]] do
				Add(stratum, i);
			od;
		fi;
	od;
	return AsSortedList(stratum);
end);

InstallMethod(TranslationsOfOrigami, [IsOrigami],function(origami)
	local G,O, list,i,j;
	G:=NormalformConjugators(origami); #permutations to a normalform. for each of the tiles one
	O:=List(G,i->Origami(i^-1*HorizontalPerm(origami)*i, i^-1*VerticalPerm(origami)*i)); #origamis derived from the permutations above
	list:=[];
	for i in [1 .. Length(O)] do
	 if Length(Positions(O,O[i]))=1 then;
	 else
	 for j in Positions(O, O[i]) do
	Add(list, G[i]*Inverse(G[j]));
	od;
	fi;
	od;
return DuplicateFreeList(list);
end);

InstallMethod(IsHyperelliptic, [IsOrigami], function(origami)
	local g,n,b,L,bool,x,y,i, sigma;
	n:=2; #degree of th covering
	x:=HorizontalPerm(origami);
	y:=VerticalPerm(origami);
	g:=Genus(origami);

L:=ConjugatorsToInverse(origami);
L:=Filtered(L, i->Order(i)=2);
if L=[] then return false;
else
	for sigma in L do
		b:=0;#fixpoints
			b:=b+Length(Difference([1.. DegreeOrigami(origami)], MovedPoints(sigma)));
			b:=b+Length(Difference([1.. DegreeOrigami(origami)], MovedPoints(sigma*x)));
			b:=b+Length(Difference([1.. DegreeOrigami(origami)], MovedPoints(sigma*y)));
			for i in [1.. DegreeOrigami(origami)] do
				if  i^(sigma*Inverse(x)*Inverse(y))=i^(y*x*Inverse(x*y)) then
					 b:=b+1;
				fi;
			od;

		if (1/n)*(g-1-(b/2))+1 = 0 then
			return true;
		fi;
	od;
	fi;
	return false;
end);
#####




##### ORIGAMI ISOMORPHISM TEST

InstallMethod(OrigamisEquivalent, [IsOrigami, IsOrigami], function(O1, O2)
	if DegreeOrigami(O1) <> DegreeOrigami(O2) then return false; fi;
	if RepresentativeAction(SymmetricGroup(DegreeOrigami(O1)), [HorizontalPerm(O1), VerticalPerm(O1)], [HorizontalPerm(O2), VerticalPerm(O2)], OnTuples) = fail
		 then return false;
	else
		return true;
	fi;
end);

#####
