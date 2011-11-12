use inc::Module::Install;
name 'Kanata-Email-Sender';
all_from 'lib/Kanata/Email/Sender.pm';

# requires '';

requires 'Any::Moose';
requires 'Email::Sender::Simple';
requires 'Email::Sender::Transport::SMTP';
requires 'Try::Tiny';
requires 'Data::Recursive::Encode';
requires 'Email::MIME';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
