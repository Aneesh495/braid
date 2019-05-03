#############################################################################
##
##  lib/qasm.gd                    braid Package
##
##  Declarations for OpenQASM 2.0 / 3.0 lexer, recursive-descent parser,
##  AST emitter, and circuit simulation execution.
##
#############################################################################

DeclareGlobalFunction( "ParseOpenQASM" );
DeclareGlobalFunction( "ParseQASMString" );
DeclareGlobalFunction( "ExecuteQASMOnTableau" );
DeclareGlobalFunction( "EmitOpenQASM" );
DeclareGlobalFunction( "QASMInstructionCount" );
