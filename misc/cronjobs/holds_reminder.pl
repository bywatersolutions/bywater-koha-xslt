#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

BEGIN {

    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use Getopt::Long;
use Pod::Usage;
use Text::CSV_XS;
use DateTime;
use DateTime::Duration;

use C4::Context;
use C4::Letters;
use C4::Log;
use Koha::DateUtils;
use Koha::Calendar;
use Koha::Libraries;

=head1 NAME

holds_reminder.pl - prepare reminder messages to be sent to patrons with waiting holds

=head1 SYNOPSIS

holds_reminder.pl
  [ -n ][ -library <branchcode> ][ -library <branchcode> ... ]
  [ -days <number of days> ][ -csv [<filename>] ][ -itemscontent <field list> ]
  [ -email <email_type> ... ]

 Options:
   -help                          brief help message
   -man                           full documentation
   -v                             verbose
   -n                             No email will be sent
   -days          <days>          days waiting to deal with
   -lettercode   <lettercode>     predefined notice to use
   -library      <branchname>     only deal with holds from this library (repeatable : several libraries can be given)
   -csv          <filename>       populate CSV file
   -html         <directory>      Output html to a file in the given directory
   -text         <directory>      Output plain text to a file in the given directory
   -itemscontent <list of fields> item information in templates
   -holidays                      use the calendar to not count holidays as waiting days
   -mtt          <message_transport_type> type of messages to send, default is email only
   -email        <email_type>     type of email that will be used. Can be 'email', 'emailpro' or 'B_email'. Repeatable.
   -optout                        if included the script will skip borrowers without holds filed notices enabled for email
=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-v>

Verbose. Without this flag set, only fatal errors are reported.

=item B<-n>

Do not send any email. Reminder notices that would have been sent to
the patrons or to the admin are printed to standard out. CSV data (if
the -csv flag is set) is written to standard out or to any csv
filename given.

=item B<-days>

Optional parameter, number of days an items has been 'waiting' on hold
to send a message for. If not included a notice will be sent to all
patrons with waiting holds.

=item B<-list-all>

Default lists only those holds that have been waiting since B<-days>
parameter.
Choose list-all to include all s waiting holds.

=item B<-library>

select notices for one specific library. Use the value in the
branches.branchcode table. This option can be repeated in order
to select notices for a group of libraries.

=item B<-csv>

Produces CSV data. if -n (no mail) flag is set, then this CSV data is
sent to standard out or to a filename if provided. Otherwise, only
notices that could not be emailed are sent in CSV format to the admin.

=item B<-html>

Produces html data. If patron does not have an email address or
-n (no mail) flag is set, an HTML file is generated in the specified
directory. This can be downloaded or further processed by library staff.
The file will be called notices-YYYY-MM-DD.html and placed in the directory
specified.

=item B<-text>

Produces plain text data. If patron does not have an email address or
-n (no mail) flag is set, a text file is generated in the specified
directory. This can be downloaded or further processed by library staff.
The file will be called notices-YYYY-MM-DD.txt and placed in the directory
specified.

=item B<-itemscontent>

comma separated list of fields that get substituted into templates in
places of the E<lt>E<lt>items.contentE<gt>E<gt> placeholder. This
defaults to due date,title,barcode,author

Other possible values come from fields in the biblios, items and
issues tables.

=item B<-holidays>

This option determines whether library holidays are used when calculating how
long an item has been waiting. If enabled the count will skip closed days.

=item B<-date>

use it in order to send notices on a specific date and not Now. Format: YYYY-MM-DD.

=item B<-email>

Allows to specify which type of email will be used. Can be email, emailpro or B_email. Repeatable.

=back

=head1 DESCRIPTION

This script is designed to alert patrons and administrators of waiting
holds.

=head2 Configuration

This script sends reminders to patrons with waiting holds using a notice
defined in the Tools->Notices & slips module within Koha. The lettercode
is passed into this script and, along with other options, determine the content
of the notices sent to patrons.

=head2 Outgoing emails

Typically, messages are prepared for each patron with waiting holds.
Messages for whom there is no email address on file are collected and
sent as attachments in a single email to each library
administrator, or if that is not set, then to the email address in the
C<KohaAdminEmailAddress> system preference.

These emails are staged in the outgoing message queue, as are messages
produced by other features of Koha. This message queue must be
processed regularly by the
F<misc/cronjobs/process_message_queue.pl> program.

=head2 Templates

Templates can contain variables enclosed in double angle brackets like
E<lt>E<lt>thisE<gt>E<gt>. Those variables will be replaced with values
specific to the waiting holds or relevant patron. Available variables
are:

=over

=item E<lt>E<lt>bibE<gt>E<gt>

the name of the library

=item E<lt>E<lt>items.contentE<gt>E<gt>

one line for each item, each line containing a tab separated list of
title, author, barcode, waitingdate

=item E<lt>E<lt>borrowers.*E<gt>E<gt>

any field from the borrowers table

=item E<lt>E<lt>branches.*E<gt>E<gt>

any field from the branches table

=back

=head2 CSV output

The C<-csv> command line option lets you specify a file to which
hold reminder data should be output in CSV format.

With the C<-n> flag set, data about all holds is written to the
file. Without that flag, only information about holds that were
unable to be sent directly to the patrons will be written. In other
words, this CSV file replaces the data that is typically sent to the
administrator email address.

=head1 USAGE EXAMPLES

C<holds_reminder.pl> - With no arguments the simple help is printed

C<holds_reminder.pl -lettercode CODE > In this most basic usage all
libraries are processed individually, and notices are prepared for
all patrons with waiting holds for whom we have email addresses.
Messages for those patrons for whom we have no email
address are sent in a single attachment to the library administrator's
email address, or to the address in the KohaAdminEmailAddress system
preference.

C<holds_reminder.pl -lettercode CODE -n -csv /tmp/holds_reminder.csv> - sends no email and
populates F</tmp/holds_reminder.csv> with information about all waiting holds
items.

C<holds_reminder.pl -lettercode CODE -library MAIN -days 14> - prepare notices of
holds waiting for 2 weeks for the MAIN library.

C<holds_reminder.pl -library MAIN -days 14 -list-all> - prepare notices
of holds waiting for 2 weeks for the MAIN library and include all the
patron's waiting hold

=cut

# These variables are set by command line options.
# They are initially set to default values.
my $dbh = C4::Context->dbh();
my $help    = 0;
my $man     = 0;
my $verbose = 0;
my $nomail  = 0;
my $days    ;
my $lettercode;
my @branchcodes; # Branch(es) passed as parameter
my @emails_to_use;    # Emails to use for messaging
my @emails;           # Emails given in command-line parameters
my @message_transport_types;
my $csvfilename;
my $htmlfilename;
my $text_filename;
my $triggered = 0;
my $listall = 0;
my $itemscontent = join( ',', qw( waitingdate title barcode author itemnumber ) );
my $use_calendar = 0;
my ( $date_input, $today );
my $opt_out = 0;

GetOptions(
    'help|?'         => \$help,
    'man'            => \$man,
    'v'              => \$verbose,
    'n'              => \$nomail,
    'days=s'         => \$days,
    'lettercode=s'   => \$lettercode,
    'library=s'      => \@branchcodes,
    'csv:s'          => \$csvfilename,    # this optional argument gets '' if not supplied.
    'html:s'         => \$htmlfilename,    # this optional argument gets '' if not supplied.
    'text:s'         => \$text_filename,    # this optional argument gets '' if not supplied.
    'itemscontent=s' => \$itemscontent,
    'list-all'       => \$listall,
    't|triggered'    => \$triggered,
    'date=s'         => \$date_input,
    'email=s'        => \@emails,
    'mtt=s'          => \@message_transport_types,
    'holidays'       => \$use_calendar,
    'optout'         => \$opt_out
) or pod2usage(1);
pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

if ( !$lettercode ) {
    pod2usage({
        -exitval => 1,
        -msg => qq{\nError: You must specify a lettercode to send reminders.\n},
    });
}


cronlogaction();

unless (defined $days) {
    $days=0;
    $listall=1;
}

if ( defined $csvfilename && $csvfilename =~ /^-/ ) {
    warn qq(using "$csvfilename" as filename, that seems odd);
}

my $PrintNoticesMaxLines = C4::Context->preference('PrintNoticesMaxLines');

if (scalar @branchcodes > 0) {
    my $branchcodes_word = scalar @branchcodes > 1 ? 'branches' : 'branch';
    $verbose and warn "$branchcodes_word @branchcodes passed on parameter\n";
}
else {
    my $branches = Koha::Libraries->search( {} , {columns => 'branchcode' } );
    while ( my $branch = $branches->next ) {
        push @branchcodes, $branch->branchcode;
    }
}

my $date_to_run;
my $date;
if ( $date_input ){
    eval {
        $date_to_run = dt_from_string( $date_input, 'iso' );
    };
    die "$date_input is not a valid date, aborting! Use a date in format YYYY-MM-DD."
        if $@ or not $date_to_run;
    $date = $dbh->quote( $date_input );
}
else {
    $date="NOW()";
    $date_to_run = dt_from_string();
}


# these are the fields that will be substituted into <<item.content>>
my @item_content_fields = split( /,/, $itemscontent );

binmode( STDOUT, ':encoding(UTF-8)' );


our $csv;       # the Text::CSV_XS object
our $csv_fh;    # the filehandle to the CSV file.
if ( defined $csvfilename ) {
    my $sep_char = C4::Context->preference('delimiter') || ';';
    $sep_char = "\t" if ($sep_char eq 'tabulation');
    $csv = Text::CSV_XS->new( { binary => 1 , sep_char => $sep_char } );
    if ( $csvfilename eq '' ) {
        $csv_fh = *STDOUT;
    } else {
        open $csv_fh, ">", $csvfilename or die "unable to open $csvfilename: $!";
    }
    if ( $csv->combine(qw(name surname address1 address2 zipcode city country email phone cardnumber itemcount itemsinfo branchname letternumber)) ) {
        print $csv_fh $csv->string, "\n";
    } else {
        $verbose and warn 'combine failed on argument: ' . $csv->error_input;
    }
}

our $fh;
if ( defined $htmlfilename ) {
  if ( $htmlfilename eq '' ) {
    $fh = *STDOUT;
  } else {
    my $today = DateTime->now(time_zone => C4::Context->tz );
    open $fh, ">:encoding(UTF-8)",File::Spec->catdir ($htmlfilename,"notices-".$today->ymd().".html");
  }

  print $fh "<html>\n";
  print $fh "<head>\n";
  print $fh "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n";
  print $fh "<style type='text/css'>\n";
  print $fh "pre {page-break-after: always;}\n";
  print $fh "pre {white-space: pre-wrap;}\n";
  print $fh "pre {white-space: -moz-pre-wrap;}\n";
  print $fh "pre {white-space: -o-pre-wrap;}\n";
  print $fh "pre {word-wrap: break-work;}\n";
  print $fh "</style>\n";
  print $fh "</head>\n";
  print $fh "<body>\n";
}
elsif ( defined $text_filename ) {
  if ( $text_filename eq '' ) {
    $fh = *STDOUT;
  } else {
    my $today = DateTime->now(time_zone => C4::Context->tz );
    open $fh, ">",File::Spec->catdir ($text_filename,"notices-".$today->ymd().".txt");
  }
}

foreach my $branchcode (@branchcodes) { #BEGIN BRANCH LOOP
    if ( C4::Context->preference('OverdueNoticeCalendar') ) {
        my $calendar = Koha::Calendar->new( branchcode => $branchcode );
        if ( $calendar->is_holiday($date_to_run) ) {
            next;
        }
    }

    my $letter = C4::Letters::getletter( 'reserves', $lettercode , $branchcode );
    unless ($letter) {
        $verbose and warn qq|Message '$lettercode' content not found|;
        # might as well skip this branch, no borrowers are going to work.
        next;
    }

    my $library             = Koha::Libraries->find($branchcode);
    my $admin_email_address = $library->branchemail
      || C4::Context->preference('KohaAdminEmailAddress');
    my @output_chunks;    # may be sent to mail or stdout or csv file.

    $verbose and warn sprintf "branchcode : '%s' using %s\n", $branchcode, $admin_email_address;

    my $sth2 = $dbh->prepare( <<"END_SQL" );
SELECT biblio.*, items.*, reserves.*, biblioitems.itemtype, branchname
  FROM reserves,items,biblio, biblioitems, branches b
  WHERE reserves.found = 'W'
    AND items.itemnumber=reserves.itemnumber
    AND biblio.biblionumber   = items.biblionumber
    AND b.branchcode = items.homebranch
    AND biblio.biblionumber   = biblioitems.biblionumber
    AND reserves.borrowernumber = ?
    AND TO_DAYS($date)-TO_DAYS(reserves.waitingdate) >= $days
END_SQL

    my $borrower_sql = <<"END_SQL";
SELECT reserves.borrowernumber, firstname, surname, address, address2, city, zipcode, country, email, emailpro, B_email, smsalertnumber, phone, cardnumber, waitingdate
FROM   reserves,borrowers,categories
WHERE  reserves.borrowernumber=borrowers.borrowernumber
AND    borrowers.categorycode=categories.categorycode
AND    TO_DAYS($date)-TO_DAYS(reserves.waitingdate) >= 0
AND    reserves.branchcode=?
END_SQL


    if ($opt_out) {
    $borrower_sql = <<"END_SQL";
SELECT reserves.borrowernumber, firstname, surname, address, address2, city, zipcode, country, email, emailpro, B_email, smsalertnumber, phone, cardnumber, waitingdate
FROM   reserves,borrowers,categories,borrower_message_preferences,borrower_message_transport_preferences
WHERE  reserves.borrowernumber=borrowers.borrowernumber
AND    borrower_message_preferences.borrowernumber = borrowers.borrowernumber
AND    borrower_message_preferences.message_attribute_id = 4
AND    borrower_message_preferences.borrower_message_preference_id = borrower_message_transport_preferences.borrower_message_preference_id
AND    borrower_message_transport_preferences.message_transport_type= "email"
AND    borrowers.categorycode=categories.categorycode
AND    TO_DAYS($date)-TO_DAYS(reserves.waitingdate) >= 0
AND    reserves.branchcode=?
END_SQL
    }

    my @borrower_parameters;
    push @borrower_parameters, $branchcode;


    # $sth gets borrower info iff at least one waiting reserve has triggered the action.
    my $sth = $dbh->prepare($borrower_sql);
    $sth->execute(@borrower_parameters);
    $verbose and warn $borrower_sql . "\n $branchcode " . "\n ($date, ".  $date_to_run->datetime() .")\nreturns " . $sth->rows . " rows";
    my $borrowernumber;
    while ( my $data = $sth->fetchrow_hashref ) { #BEGIN BORROWER LOOP
        # check the borrower has at least one item that matches
        my $days_waiting;
               if ( $use_calendar )
                {
                    my $calendar =
                      Koha::Calendar->new( branchcode => $branchcode );
                    $days_waiting =
                      $calendar->days_between( dt_from_string($data->{waitingdate}),
                        $date_to_run );
                }
                else {
                    $days_waiting =
                      $date_to_run->delta_days( dt_from_string($data->{waitingdate}) );
                }
                $days_waiting = $days_waiting->in_units('days');
                if ($days) { next unless ( $days_waiting == $days ); }

                if (defined $borrowernumber && $borrowernumber eq $data->{'borrowernumber'}){
                # we have already dealt with this borrower
                    $verbose and warn "already dealt with this borrower $borrowernumber";
                    next;
                }
                $borrowernumber = $data->{'borrowernumber'};
                my $borr =
                    $data->{'firstname'} . ', '
                  . $data->{'surname'} . ' ('
                  . $borrowernumber . ')';
                $verbose
                  and warn "borrower $borr has holds triggering notice.";

                @emails_to_use = ();
                my $notice_email =
                    C4::Members::GetNoticeEmailAddress($borrowernumber);
                unless ($nomail) {
                    if (@emails) {
                        foreach (@emails) {
                            push @emails_to_use, $data->{$_} if ( $data->{$_} );
                        }
                    }
                    else {
                        push @emails_to_use, $notice_email if ($notice_email);
                    }
                }

                my @params = ($borrowernumber);
                $verbose and warn "STH2 PARAMS: borrowernumber = $borrowernumber";

                $sth2->execute(@params);
                my $holdcount = 0;
                my $titles = "";
                my @holds = ();

                my $j = 0;
                my $exceededPrintNoticesMaxLines = 0;
                while ( my $hold_info = $sth2->fetchrow_hashref() ) { #BEGIN HOLDS LOOP
                    if ( $use_calendar ) {
                        my $calendar =
                          Koha::Calendar->new( branchcode => $branchcode );
                        $days_waiting =
                          $calendar->days_between(
                            dt_from_string( $hold_info->{waitingdate} ), $date_to_run );
                    }
                    else {
                        $days_waiting =
                          $date_to_run->delta_days(
                            dt_from_string( $hold_info->{waitingdate} ) );
                    }
                    $days_waiting = $days_waiting->in_units('days');
                    unless ($listall) { next unless ( $days_waiting == $days ); }

                    if ( ( scalar(@emails_to_use) == 0 || $nomail ) && $PrintNoticesMaxLines && $j >= $PrintNoticesMaxLines ) {
                      $exceededPrintNoticesMaxLines = 1;
                      last;
                    }
                    $j++;
                    my @hold_info = map { $_ =~ /^date|date$/ ?
                                           eval { output_pref( { dt => dt_from_string( $hold_info->{$_} ), dateonly => 1 } ); }
                                           :
                                           $hold_info->{$_} || '' } @item_content_fields;
                    $titles .= join("\t", @hold_info) . "\n";
                    $holdcount++;
                    push @holds, $hold_info;
                } #END HOLD LOOP
                $sth2->finish;

                @message_transport_types = ('email') unless ( scalar @message_transport_types > 0 );


                my $print_sent = 0; # A print notice is not yet sent for this patron
                for my $mtt ( @message_transport_types ) {
                    my $effective_mtt = $mtt;
                    if ( ($mtt eq 'email' and not scalar @emails_to_use) or ($mtt eq 'sms' and not $data->{smsalertnumber}) ) {
                        # email or sms is requested but not exist, do a print.
                        $effective_mtt = 'print';
                    }

                    my $letter_exists = C4::Letters::getletter( 'reserves', $lettercode, $branchcode, $effective_mtt ) ? 1 : 0;
                    my $letter = GetPreparedLetter(
                           module          => 'reserves',
                            letter_code     => $lettercode,
                            borrowernumber  => $borrowernumber,
                            branchcode      => $branchcode,
                            repeat           => { item => \@holds},
                            tables          => { 'borrowers' => $borrowernumber, 'branches' => $branchcode },
                            substitute      => {
                                               'items.content' => $titles,
                                               'count'         => $holdcount,
                                               },
                            # If there is no template defined for the requested letter
                            # Fallback on email
                            message_transport_type => $letter_exists ? $effective_mtt : 'email',

                    );
                    unless ($letter) {
                        $verbose and warn qq|Message '$lettercode' content not found|;
                        # this transport doesn't have a configured notice, so try another
                        next;
                    }

                    if ( $exceededPrintNoticesMaxLines ) {
                      $letter->{'content'} .= "List too long for form; please check your account online for a complete list of your waiting holds.";
                    }

                    my @misses = grep { /./ } map { /^([^>]*)[>]+/; ( $1 || '' ); } split /\</, $letter->{'content'};
                    if (@misses) {
                        $verbose and warn "The following terms were not matched and replaced: \n\t" . join "\n\t", @misses;
                    }

                    if ($nomail) {
                        push @output_chunks,
                          prepare_letter_for_printing(
                          {   letter         => $letter,
                              borrowernumber => $borrowernumber,
                              firstname      => $data->{'firstname'},
                              lastname       => $data->{'surname'},
                              address1       => $data->{'address'},
                              address2       => $data->{'address2'},
                              city           => $data->{'city'},
                              phone          => $data->{'phone'},
                              cardnumber     => $data->{'cardnumber'},
                              branchname     => $library->branchname,
                              postcode       => $data->{'zipcode'},
                              country        => $data->{'country'},
                              email          => $notice_email,
                              itemcount      => $holdcount,
                              titles         => $titles,
                              outputformat   => defined $csvfilename ? 'csv' : defined $htmlfilename ? 'html' : defined $text_filename ? 'text' : '',
                            }
                          );
                    } else {
                        if ( ($mtt eq 'email' and not scalar @emails_to_use) or ($mtt eq 'sms' and not $data->{smsalertnumber}) ) {
                            push @output_chunks,
                              prepare_letter_for_printing(
                              {   letter         => $letter,
                                  borrowernumber => $borrowernumber,
                                  firstname      => $data->{'firstname'},
                                  lastname       => $data->{'surname'},
                                  address1       => $data->{'address'},
                                  address2       => $data->{'address2'},
                                  city           => $data->{'city'},
                                  postcode       => $data->{'zipcode'},
                                  country        => $data->{'country'},
                                  email          => $notice_email,
                                  itemcount      => $holdcount,
                                  titles         => $titles,
                                  outputformat   => defined $csvfilename ? 'csv' : defined $htmlfilename ? 'html' : defined $text_filename ? 'text' : '',
                                }
                              );
                        }
                        unless ( $effective_mtt eq 'print' and $print_sent == 1 ) {
                            # Just sent a print if not already done.
                            C4::Letters::EnqueueLetter(
                                {   letter                 => $letter,
                                    borrowernumber         => $borrowernumber,
                                    message_transport_type => $effective_mtt,
                                    from_address           => $admin_email_address,
                                    to_address             => join(',', @emails_to_use),
                                }
                            );
                            # A print notice should be sent only once
                            # Without this check, a print could be sent twice or more if the library checks sms and email and print and the patron has no email or sms number.
                            $print_sent = 1 if $effective_mtt eq 'print';
                        }
                    }
                }
            } #END BORROWER LOOP
            $sth->finish;

    if (@output_chunks) {
        if ( defined $csvfilename ) {
            print $csv_fh @output_chunks;
        }
        elsif ( defined $htmlfilename ) {
            print $fh @output_chunks;
        }
        elsif ( defined $text_filename ) {
            print $fh @output_chunks;
        }
        elsif ($nomail){
                local $, = "\f";    # pagebreak
                print @output_chunks;
        }
        # Generate the content of the csv with headers
        my $content;
        if ( defined $csvfilename ) {
            my $delimiter = C4::Context->preference('delimiter') || ';';
            $content = join($delimiter, qw(title name surname address1 address2 zipcode city country email itemcount itemsinfo due_date issue_date)) . "\n";
        }
        else {
            $content = "";
        }
        $content .= join( "\n", @output_chunks );

        my $attachment = {
            filename => defined $csvfilename ? 'attachment.csv' : 'attachment.txt',
            type => 'text/plain',
            content => $content,
        };

        my $letter = {
            title   => 'Overdue Notices',
            content => 'These messages were not sent directly to the patrons.',
        };
        C4::Letters::EnqueueLetter(
            {   letter                 => $letter,
                borrowernumber         => undef,
                message_transport_type => 'email',
                attachments            => [$attachment],
                to_address             => $admin_email_address,
            }
        );
    }

} #END BRANCH LOOP
if ($csvfilename) {
    # note that we're not testing on $csv_fh to prevent closing
    # STDOUT.
    close $csv_fh;
}

if ( defined $htmlfilename ) {
  print $fh "</body>\n";
  print $fh "</html>\n";
  close $fh;
} elsif ( defined $text_filename ) {
  close $fh;
}

=head1 INTERNAL METHODS

These methods are internal to the operation of holds_reminder.pl.

=head2 prepare_letter_for_printing

returns a string of text appropriate for printing in the event that an
holds reminder notice will not be sent to the patron's email
address. Depending on the desired output format, this may be a CSV
string, or a human-readable representation of the notice.

required parameters:
  letter
  borrowernumber

optional parameters:
  outputformat

=cut

sub prepare_letter_for_printing {
    my $params = shift;

    return unless ref $params eq 'HASH';

    foreach my $required_parameter (qw( letter borrowernumber )) {
        return unless defined $params->{$required_parameter};
    }

    my $return;
    chomp $params->{titles};
    if ( exists $params->{'outputformat'} && $params->{'outputformat'} eq 'csv' ) {
        if ($csv->combine(
                $params->{'firstname'}, $params->{'lastname'}, $params->{'address1'},  $params->{'address2'}, $params->{'postcode'},
                $params->{'city'}, $params->{'country'}, $params->{'email'}, $params->{'phone'}, $params->{'cardnumber'},
                $params->{'itemcount'}, $params->{'titles'}, $params->{'branchname'}
            )
          ) {
            return $csv->string, "\n";
        } else {
            $verbose and warn 'combine failed on argument: ' . $csv->error_input;
        }
    } elsif ( exists $params->{'outputformat'} && $params->{'outputformat'} eq 'html' ) {
      $return = "<pre>\n";
      $return .= "$params->{'letter'}->{'content'}\n";
      $return .= "\n</pre>\n";
    } else {
        $return .= "$params->{'letter'}->{'content'}\n";

    }
    return $return;
}
