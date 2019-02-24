#############################################################################
##
##  PackageInfo.g for the package "braid"
##
##  braid: Fault-Tolerant Quantum Compilation, Stabilizer Circuit Synthesis,
##         and Topological Error Correction Engine
##
SetPackageInfo( rec(
  PackageName := "braid",
  Subtitle := "Fault-Tolerant Quantum Compilation and Topological Error Correction",
  Version := "1.0.0",
  Date := "15/11/2026",
  
  Persons := [
    rec(
      LastName := "Parthasarathy",
      FirstNames := "Aneesh Krishna",
      IsAuthor := true,
      IsMaintainer := true,
      Email := "aneeshkrishnaparthasarathy@gmail.com",
      PostalAddress := "San Francisco, CA, USA",
      Place := "San Francisco",
      Institution := "University of California"
    )
  ],

  Status := "dev",
  CommunicatedBy := "",
  AcceptDate := "",

  Description := Concatenation(
    "braid is an industrial-scale quantum computing package for GAP. ",
    "It implements the Gottesman-Knill stabilizer tableau formalism, ",
    "symplectic Bruhat decomposition for optimal Clifford gate synthesis, ",
    "topological surface codes on planar lattices, group-algebra Quantum LDPC ",
    "(QLDPC) codes, Minimum-Weight Perfect Matching (MWPM) decoding, ",
    "magic state distillation routines, and OpenQASM 2.0/3.0 parsing."
  ),

  PackageWWWHome := "https://github.com/Aneesh495/braid",
  ArchiveURL := "https://github.com/Aneesh495/braid/archive/main",
  ArchiveFormats := ".tar.gz",

  Dependencies := rec(
    GAP := ">= 4.10.0",
    NeededOtherPackages := [ ],
    SuggestedOtherPackages := [ ],
    ExternalConditions := [ ]
  ),

  AvailabilityTest := ReturnTrue,
  
  TestFile := "tst/testall.g",
  
  Keywords := [
    "quantum computing",
    "stabilizer codes",
    "quantum error correction",
    "Clifford group",
    "symplectic group",
    "surface codes",
    "quantum LDPC",
    "MWPM decoding",
    "Gottesman-Knill theorem"
  ]
));
