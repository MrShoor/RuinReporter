{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit RuinReporter;

{$warn 5023 off : no warning about unused units}
interface

uses
  RuinR, _RuinReport, _RuinTypes, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('RuinReporter', @Register);
end.
