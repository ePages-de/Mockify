requires 'perl', '5.010';

requires 'Module::Load';
requires 'Test::MockObject::Extends';
requires 'Data::Compare';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

