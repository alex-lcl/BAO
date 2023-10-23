#/usr/bin/perl
<<DOC; 
Votre Nom : Alexandra Li COMBEAU LONGUET
MARS 2021
 usage : perl parcours-arborescence-fichiers repertoire-a-parcourir
 Le programme prend en entrée le nom du répertoire contenant les fichiers
 é traiter
 Le programme construit en sortie un fichier structuré contenant sur chaque
 ligne le nom du fichier et le résultat du filtrage :
<FICHIER><NOM>du fichier</NOM></FICHIER><CONTENU>du filtrage</CONTENU></FICHIER>
DOC
#-----------------------------------------------------------
use XML::RSS;
use Data::Dumper;
use Data::Dump qw(dump);
#use strict;
#use warnings;
binmode(STDOUT, ":encoding(UTF-8)");
#-----------------------------------------------------------
# on s'assure que le nom du répertoire ne se termine pas par un "/"
my $rep="$ARGV[0]";
my $rep=~ s/[\/]$//;
my $rubrique="$ARGV[1]";
#----------------------------------------
open my $output, ">:encoding(UTF-8)", "corpus-titre-description.txt";
open my $output2, ">:encoding(UTF-8)", "corpus-titre-description.xml";
#----------------------------------------
my $rss=new XML::RSS;
#----------------------------------------
&parcoursarborescencefichiers($rep);	#recurse!
close $output;
close $output2;
#----------------------------------------------
sub parcoursarborescencefichiers {
    my $path = shift(@_);
    opendir(my $DIRhandle, $path) or die "can't open $path: $!\n";
    my @files = readdir($DIRhandle);
    closedir($DIRhandle);
    foreach my $file (@files) {
		next if $file =~ /^\.\.?$/;
		$file = $path."/".$file;
		if (-d $file) {
			print "on entre dans $file \n";
			&parcoursarborescencefichiers($file);	#recurse!
			print "on sort de $file \n";
		}
		if (-f $file) {
# 	      TRAITEMENT à réaliser sur chaque fichier pour une rubrique
#   	    Insérer ici votre code (le filtreur)
			# on doit régler le fait de ne traiter que les fichiers XML
			# on ne veut traiter qu'une seule rubrique à chaque fois
			# A FAIRE : PAS DE DUPLICATA DES ITEMS; INDICE, IL FAUT LES MEMORISER EN MEMOIRE
			if ($file =~/$rubrique.+\.xml$/) {
				dump($rss);
				eval {$rss->parsefile($file); };
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
						print $output "------------------ \n";
						print $output2 "<item><titre>$titre</titre><description>$description</description></item>\n";
					}
					print "---------------------\n";
					print($rss)
				}
			}
		}
	}
}
#----------------------------------------------
sub nettoyage {
	# quand on lance une procédure
	# perl range les arguments de la procédure dans une listen# qui s'appelle @_
	my $texte=shift @_;
	# my $texte=$_[0];
	$texte =~s/<!\[CDATA\[//g;
	$texte =~s/\]\]>//g;
	#ajout de point é la fin de chaéne
	$texte =~s/$/\./g;
	$texte =~s/\.+$/\./g;
	return $texte;
}