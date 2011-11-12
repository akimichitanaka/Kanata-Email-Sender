use strict;
use Test::More;
use Kanata::Email::Sender;
use utf8;

BEGIN { use_ok 'Kanata::Email::Sender' }

{
    my $email = 'タナカアキミチ <akimichi.t@gmail.com>';
    my $email2 = '田中章道 <akimichi@thekanata.jp>';
    my $email3 = 'akimichi....-_-....@docomo.ne.jp';
    my $subject = '電子メール',
    my $body = "test\nサンプル";
    my $message = "Subject: 電子メール2\n\nサンプル2";

    my @emails = (
        {
            from     => $email,
            to       => $email2,
            cc       => [ $email, $email2 ],
            subject  => $subject,
            body     => $body,
            success  => 1,
        },
        {
            from     => $email,
            to       => $email3,
            subject  => $subject,
            message  => $message,
            success  => 1,
        },
    );

    foreach my $email (@emails) {
        my $email_sender = Kanata::Email::Sender->new($email);
        my $sendmail = $email_sender->sendmail;
        is($sendmail, 1, ref($email_sender) . ': sendmail');
    }

}

done_testing();
