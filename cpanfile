requires 'perl', '5.10.1';

requires 'Module::Load';
requires 'Test::MockObject::Extends';
requires 'Data::Compare';
requires 'Data::Dumper';
requires 'Exporter';
requires 'Scalar::Util';
requires 'experimental';
requires 'strict';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Exception';
    requires 'FindBin';
    requires 'parent';
    requires 'strict';
};

on 'build' => sub {
	requires 'Fatal';
    requires 'Perl::Critic', '1.123';
    requires 'Devel::Cover', '1.23';
    requires 'Devel::Cover::Report::Clover', '1.01';
    requires 'TAP::Harness::Archive', '0.18';
    requires 'Module::Build::Tiny', '0.039';
    requires 'Minilla', '3.0.0';
};

