gap> START_TEST( "braid: tableau" );
gap> tab1 := StabilizerTableau( 1 );;
gap> TableauNumQubits( tab1 );
1
gap> List( GetStabilizerGenerators( tab1 ), StringFromPauli );
[ "+Z" ]
gap> ApplyHadamard( tab1, 1 );;
gap> List( GetStabilizerGenerators( tab1 ), StringFromPauli );
[ "+X" ]
gap> ApplyPhase( tab1, 1 );;
gap> List( GetStabilizerGenerators( tab1 ), StringFromPauli );
[ "+Y" ]
gap> tab2 := StabilizerTableau( 2 );;
gap> List( GetStabilizerGenerators( tab2 ), StringFromPauli );
[ "+ZI", "+IZ" ]
gap> ApplyHadamard( tab2, 1 );;
gap> ApplyCNOT( tab2, 1, 2 );;
gap> stabs := List( GetStabilizerGenerators( tab2 ), StringFromPauli );;
gap> "+XX" in stabs;
true
gap> "+ZZ" in stabs;
true
gap> IsStabilizerTableauCanonical( tab2 );
true
gap> tab3 := StabilizerTableau( 3 );;
gap> ApplyHadamard( tab3, 1 );;
gap> ApplyCNOT( tab3, 1, 2 );;
gap> ApplyCNOT( tab3, 2, 3 );;
gap> ghz_stabs := List( GetStabilizerGenerators( tab3 ), StringFromPauli );;
gap> "+XXX" in ghz_stabs;
true
gap> IsStabilizerTableauCanonical( tab3 );
true
gap> STOP_TEST( "test_tableau.tst", 10000 );
