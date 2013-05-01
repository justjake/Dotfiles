use strict;
use Irssi 20020101.0250 ();
use vars qw($VERSION %IRSSI); 
$VERSION = "2.2";
%IRSSI = (
    authors     => "Timo Sirainen, Ian Peters, Winston Lee, Aaron Loessberg-Zahl",
    contact	=> "tss\@iki.fi, winst\@rescomp.berkeley.edu, amloessb\@rescomp.berkeley.edu", 
    name        => "Nick Color - ResComp Split Nick Edition",
    description => "assign a different color for each (half) nick",
    license	=> "Public Domain",
    url		=> "http://irssi.org/",
    changed	=> "2011-11-03T11:50-0800"
);

# Changelog:
# v2.2 - Fixed issue with loading single-color nicks from save file, added version check
# v2.1 - Added ability to save/load split-color nicks
# v2.0 - Implemented split-nick hashing

# Known Bugs:
# - Does janky things with users that have curly braces in their nick

# hm.. i should make it possible to use the existing one..
Irssi::theme_register([
  'pubmsg_hilight', '{pubmsghinick $0 $3 $1}$2'
]);

my %saved_colors;
my %saved_colors2;
my %session_colors = {};
my %session_colors2 = {};
my @colors = qw/2 3 4 5 6 7 9 10 11 12 13/;

sub load_colors {
  open COLORS, "$ENV{HOME}/.irssi/saved_colors";

  while (<COLORS>) {
    # I don't know why this is necessary only inside of irssi
    my @lines = split "\n";
    foreach my $line (@lines) {
      my($nick, $color, $color2) = split ":", $line;
      $saved_colors{$nick} = $color;
      $saved_colors2{$nick} = $color2;
      if (!$color2) {
        $saved_colors2{$nick} = $color;
      }
    }
  }

  close COLORS;
}

sub save_colors {
  open COLORS, ">$ENV{HOME}/.irssi/saved_colors";

  foreach my $nick (keys %saved_colors) {
    print COLORS "$nick:$saved_colors{$nick}:$saved_colors2{$nick}\n";
  }

  close COLORS;
}

# If someone we've colored (either through the saved colors, or the hash
# function) changes their nick, we'd like to keep the same color associated
# with them (but only in the session_colors, ie a temporary mapping).

sub sig_nick {
  my ($server, $newnick, $nick, $address) = @_;
  my $color;
  my $color2;
  my $s_color;
  my $s_color2;

  $newnick = substr ($newnick, 1) if ($newnick =~ /^:/);
  $color = $saved_colors{$nick};
  $color2 = $saved_colors2{$nick};
  $s_color = $session_colors{$nick};
  $s_color2 = $session_colors2{$nick};
  
  if ($color) {
    $session_colors{$newnick} = $color;
    if ($color2) {
      $session_colors2{$newnick} = $color2;
    } else {
      $session_colors2{$newnick} = $color;
    }
  } elsif ($s_color) {
    $session_colors{$newnick} = $s_color;
    if ($s_color2) {
      $session_colors2{$newnick} = $s_color2;
    } else {
      $session_colors2{$newnick} = $s_color;
    }
  }
}

# This gave reasonable distribution values when run across
# /usr/share/dict/words

sub simple_hash {
  my ($string) = @_;
  chomp $string;
  my @chars = split //, $string;
  my $counter;

  foreach my $char (@chars) {
    $counter += ord $char;
  }

  $counter = $colors[$counter % 11];

  return $counter;
}

# FIXME: breaks /HILIGHT etc.
sub sig_public {
  my ($server, $msg, $nick, $address, $target) = @_;
  my $chanrec = $server->channel_find($target);
  return if not $chanrec;
  my $nickrec = $chanrec->nick_find($nick);
  return if not $nickrec;
  my $nickmode = $nickrec->{op} ? "@" : $nickrec->{voice} ? "+" : "";
  my $use_saved_color = 0;
  
  # Has the user assigned this nick a color?
  my $color = $saved_colors{$nick};
  my $color2 = $saved_colors2{$nick};

  # Have -we- already assigned this nick a color?
  if (!$color) {
    $color = $session_colors{$nick};
    $color2 = $session_colors2{$nick};
  }
  else {
      $use_saved_color = 1;
  }

  # Split the nick in half
  my $nick1 = substr($nick,0,length($nick)/2);
  my $nick2 = substr($nick,length($nick)/2, length($nick)-1);
  
  # Let's assign this nick a (split) color
  if (!$color) {
    $color = simple_hash $nick1;
    $color = "0".$color if ($color < 10);
    $color2 = simple_hash $nick2;
    $color2 = "0".$color2 if ($color2 < 10);
    $session_colors{$nick} = $color;
    $session_colors2{$nick} = $color2;
  }

#  $color = "0".$color if ($color < 10);
#  $color2 = "0".$color2 if ($color2 < 10);

  # Finally, write the message to the screen
  $server->command('/^format pubmsg {pubmsgnick $2 {pubnick '.chr(3).$color.$nick1.chr(3).$color2.$nick2.'}}$1');

}

sub cmd_color {
  my ($data, $server, $witem) = @_;
  my ($op, $nick, $color, $color2) = split " ", $data;

  $op = lc $op;

  if (!$op) {
    Irssi::print ("No operation given");
  } elsif ($op eq "save") {
    save_colors;
  } elsif ($op eq "set") {
    if (!$nick) {
      Irssi::print ("Nick not given");
    } elsif (!$color) {
      Irssi::print ("Color not given");
    } elsif ($color < 2 || $color > 14) {
      Irssi::print ("Color must be between 2 and 14 inclusive");
    } elsif ($color2 && ($color2 < 2 || $color2 > 14)) {
      Irssi::print ("Color must be between 2 and 14 inclusive");
    } else {
      $saved_colors{$nick} = $color;
      if ($color2) {
        $saved_colors2{$nick} = $color2;
      } else {
        $saved_colors2{$nick} = $color;
      }
    }
  } elsif ($op eq "clear") {
    if (!$nick) {
      Irssi::print ("Nick not given");
    } else {
      delete ($saved_colors{$nick});
    }
  } elsif ($op eq "list") {
    Irssi::print ("\nSaved Colors:");
    foreach my $nick (keys %saved_colors) {
      # Split the nick in half
      my $nick1 = substr($nick,0,length($nick)/2);
      my $nick2 = substr($nick,length($nick)/2, length($nick)-1);
      my $c1 = $saved_colors{$nick};
      my $c2 = $saved_colors2{$nick};
      if (!$c2) {
        $c2 = $saved_colors{$nick};
      }
      Irssi::print (chr(3) . "$c1$nick1" .
                    chr(3) . "$c2$nick2" . chr(3) . chr(3));
#      Irssi::print (chr (3) . "$saved_colors{$nick}$nick" .
#		    chr (3) . "1 ($saved_colors{$nick})");
    }
  } elsif ($op eq "preview") {
    Irssi::print ("\nAvailable colors:");
    foreach my $i (2..14) {
      Irssi::print (chr (3) . "$i" . "Color #$i");
    }
  } elsif ($op eq "version") {
      Irssi::print($IRSSI{name});
      Irssi::print("version " . $VERSION); 
  } elsif ($op eq "help") {
      Irssi::print("\nAvailable commands:");
      Irssi::print("save");
      Irssi::print("└─>saves set colors");
      Irssi::print("set <nick> <color> [color2]");
      Irssi::print("└─>manually sets color(s) (2-14) for the nick");
      Irssi::print("clear <nick>");
      Irssi::print("└─>clears manual colors for the nick");
      Irssi::print("list");
      Irssi::print("└─>lists manual color settings");
      Irssi::print("preview");
      Irssi::print("└─>shows a preview of selectable colors");
      Irssi::print("version");
      Irssi::print("└─>prints this plugin's version number");
  } else {
      Irssi::print("\nInvalid argument to /color");
  }
}

load_colors;

Irssi::command_bind('color', 'cmd_color');

Irssi::signal_add('message public', 'sig_public');
Irssi::signal_add('event nick', 'sig_nick');
