#!/usr/bin/perl
# ce programme doit traiter un fil RSS (1/1/2020, 3208
# et en extraire tous les titres et descriptions de tous les items
# on lance le programme comme ceci :
# perl 01_titre-description.pl arborescence-filsdumonde-2020-tljours-19h/2020/01/01/18-09-00/0,2-3208,1-0,0.xml
use strict;
use utf8;
binmode(STDOUT, ":utf8");

undef $/; #contient à l'origine "\n"

open my $input, "<:encoding(UTF-8)", "$ARGV[0]"; # or die "$!";
open my $output, ">:encoding(UTF-8)", "corpus-titre-description.txt";
open my $output2, ">:encoding(UTF-8)", "corpus-titre-description.xml";

my $ligne=<$input>;
#print "On lit une ligne \n";
#print "\nAppuyez sur entrée pour continuer";
#my $au=<STDIN>;
#tant que l'expression régulière est fructueuse (avec g, recherche globale, et s pour intégrer les auts de lignes)

print $output2 "<?xml version=\"1.0\" encoding=\"utf8\"?>\n<corpus>\n";
while ($ligne =~ /<item><title>(.+?)<\/title>.+?<description>(.+?)<\/description>/gs) {
	my $titre=&nettoyage($1);
	my $description=&nettoyage($2);
	print $output "$titre \n";
	print $output "$description \n";
	print $output "------------------ \n";
	print $output2 "<item><titre>$titre</titre><description>$description</description></item>\n";
}
print $output2 "</corpus>\n";

close $input;
close $output;
close $output2;
#------------------------------------------------------
sub nettoyage {
	# quand on lance une procédure
	# perl range les arguments de la procédure dans une listen# qui s'appelle @_
	my $texte=shift @_;
	# my $texte=$_[0];
	$texte =~s/<!\[CDATA\[//g;
	$texte =~s/\]\]>//g;
	#ajout de point à la fin de chaîne
	$texte =~s/$/\./g;
	$texte =~s/\.+$/\./g;
	return $texte;
}