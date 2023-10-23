#!/usr/bin/perl
use XML::RSS;
use Data::Dumper;
use Data::Dump qw(dump);
use strict;
use warnings;
binmode(STDOUT, ":encoding(UTF-8)");
#-----------------------------------------------------------
my $file="$ARGV[0]";
my $rss=new XML::RSS; # créé l'objet XML::RSS
#-----------------------------------------------------------
open my $output, ">:encoding(UTF-8)","corpus-titre-description.txt";
open my $output2, ">:encoding(UTF-8)","corpus-titre-description.xml";
#-----------------------------------------------------------
print $output2 "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<corpus>\n";
eval {$rss->parsefile($file); };  # on remplit l'objet via parsefile
if( $@ ) {
    $@ =~ s/at \/.*?$//s;               # remove module line number
    print STDERR "\nERROR in '$file':\n$@\n";
} 
else {
	
	foreach my $item (@{$rss->{'items'}}) {
		my $titre=&nettoyage($item->{'title'});
		my $description=&nettoyage($item->{'description'});
		print $output "$titre \n";
		print $output "$description \n";
		print $output "----------------------------\n";
		print $output2 "<item><titre>$titre</titre><description>$description</description></item>\n";
	}
	print "---------------------\n";
	
}
print $output2 "</corpus>\n";
close $output;
close $output2;
#------------------------------------------------
sub nettoyage {
	my $texte=shift @_;
	$texte=~s/(^<!\[CDATA\[)|(\]\]>$)//g;
	$texte.=".";
	$texte=~s/\.+$/\./;
	return $texte;
}