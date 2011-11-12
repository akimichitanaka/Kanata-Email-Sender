package Kanata::Email::Sender;

use Any::Moose;
use Carp;
use Encode;
use Email::MIME;
use Email::Sender::Simple;
use Email::Sender::Transport::SMTP qw();
use Data::Recursive::Encode;
use Try::Tiny;
use Data::Dumper;

our $VERSION = '0.01';

has 'from' => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

has 'to' => (
    is => 'rw',
    required => 1,
);

has 'cc' => (
    is => 'rw',
);

has 'bcc' => (
    is => 'rw',
);

has 'subject' => (
    is => 'rw',
    isa => 'Str',
);

has 'message' => (
    is => 'rw',
    isa => 'Str',
);

has 'body' => (
    is => 'rw',
    isa => 'Str',
);

has 'attributes' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub {
        {
            content_type => 'text/plain',
            charset  => 'ISO-2022-JP',
            encoding => '7bit',
        }
    },
);

sub sendmail {
    my ($self, $attributes) = @_;

    $self->_parse_message;
    my $header = $self->_create_header;
    my $envelope = $self->_create_envelope;

    my $email = Email::MIME->create(
        header     => $header,
        attributes => $attributes || $self->attributes,
        body_str   => encode( 'iso-2022-jp', $self->body, Encode::FB_PERLQQ)
    );
    try {
        Email::Sender::Simple->send($email, $envelope);
        return 1;
    } catch {
        carp __PACKAGE__ . ": sending failed: $_";
        return;
    };
}

sub _create_header {
    my $self = shift;

    my $header = Data::Recursive::Encode->encode(
        'MIME-Header-ISO_2022_JP' => [
            To      => $self->_parse_envelope($self->to),
            From    => $self->from,
            Subject => $self->subject,
            Cc      => $self->_parse_envelope($self->cc),
            Bcc     => $self->_parse_envelope($self->bcc)
        ]
    );

    return $header;
}

sub _parse_envelope {
    my ( $self, $envelope ) = @_;
    return ( ref($envelope) eq 'ARRAY' ) ? join(", ", @$envelope) : $envelope;
}

sub _create_envelope {
    my $self = shift;

    my $envelope = Data::Recursive::Encode->encode(
        'MIME-Header-ISO_2022_JP' => {
            'to'   => $self->_parse_envelope($self->to),
            'from' => $self->from,
        }
    );

    return $envelope;
}

sub _parse_message {
    my $self = shift;

    if ( my $message = $self->message ) {
        # convert line break
        $message =~ s/\r\n|\r/\n/g;

        # $message の最初の空行までをヘッダとみなす
        my ($header, $body) = split /\n\n/, $message, 2;

        # extract headers
        my $current_header;
        for (split /\n/, $header) {
            if (/^(\S+?):\s+(.+)$/) {
                $current_header = lc($1);
                $self->$current_header($2);
            } elsif (/^\s+(.+)$/) {
                my $value = $self->$current_header . ' ' . $1;
                $self->$current_header($value);
            }
        }

        $self->body($body);
    }
}


__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;

__END__

=head1 NAME

Kanata::Email::Sender -

=head1 SYNOPSIS

  use Kanata::Email::Sender;

=head1 DESCRIPTION

Kanata::Email::Sender is

=head1 AUTHOR

akimichi E<lt>akimichi@thekanata.jpE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
