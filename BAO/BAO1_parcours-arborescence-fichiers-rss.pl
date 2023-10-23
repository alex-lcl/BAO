#/usr/bin/perl
<<DOC; 
Votre Nom : Alexandra LI COMBEAU LONGUET
 usage : perl parcours-arborescence-fichiers repertoire-a-parcourir rubrique
 Le programme prend en entrée le nom du répertoire-racine contenant les fichiers
 à traiter et le nom de la rubrique à traiter parmi ces fichiers
DOC
#-----------------------------------------------------------
use strict;
use utf8;
use XML::RSS;
use Data::Dumper;
use Data::Dump qw(dump);
binmode(STDOUT, ":encoding(UTF-8)");
#-----------------------------------------------------------
my $rep="$ARGV[0]";
my $rubrique ="$ARGV[1]";
# on s'assure que le nom du répertoire ne se termine pas par un "/"
$rep=~ s/[\/]$//;
open my $OUT ,">:encoding(utf8)","sortie-slurp_$rubrique.txt";
open my $OUTXML,">:encoding(utf8)","sortiexml-slurp_$rubrique.xml";
print $OUTXML "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n";
print $OUTXML "<corpus2020>\n";
my %dico_des_titres=();
my $numberItem=0;
my $nbFile=0;
#----------------------------------------
&parcoursarborescencefichiers($rep);	#recurse!
#----------------------------------------
print $OUTXML "</corpus2020>\n";
close $OUT;
close $OUTXML;
print "Nb item : $numberItem \n";
exit;
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
			&parcoursarborescencefichiers($file);	#recurse!
		}
		if (-f $file) {
			if ($file =~/$rubrique.+xml$/) {
				print $nbFile++," Traitement de : ",$file,"\n";
				my $rss=new XML::RSS;
				dump($rss);
				eval {$rss->parsefile($file); }; # sur $rss, je veux appliquer (->) la fonction parsefile
				#eval sert à s'assurer que le remplissage du fichier se passe bien et réccupérer une erreur précise s'il y en a 
				if( $@ ) {
					$@ =~ s/at \/.*?$//s;               # remove module line number
					print STDERR "\nERROR in '$file':\n$@\n";
				} 
				else {
					foreach my $item (@{$rss->{'items'}}) {
						$numberItem++;
						my $titre= $item->{'title'};
						my $description= $item->{'description'};
						if (!(exists $dico_des_titres{$titre})) { 
							$dico_des_titres{$titre}=$description ;
							#Appel du sous-programme de nettoyage 
							($titre,$description)=&nettoyage($titre,$description);
							#Ecriture des résultats en sorties
							print $OUT $titre,"\n";
							print $OUT $description,"\n";
							print $OUT "--------------------\n";
							print $OUTXML "<item>\n";
							print $OUTXML "<titre>$titre</titre>\n";
							print $OUTXML "<description>$description</description>\n";
							print $OUTXML "</item>\n";
						}
					}
				}
			}
		}
    }
}
#----------------------------------------------
sub nettoyage {
    #my $titre=shift(@_); autre solution en vidant la liste des arguments du programmes...
    #my $description=shift(@_);
    my $titre = $_[0];
    my $description = $_[1];
	$titre=~s/^<!\[CDATA\[//;
	$titre=~s/\]\]>$//;
	$description=~s/^<!\[CDATA\[//;
	$description=~s/\]\]>$//;
    $description=~s/&lt;.+?&gt;//g;
    $description=~s/&#38;#39;/'/g;
    $description=~s/&#38;#34;/"/g;
    $titre=~s/&lt;.+?&gt;//g;
    $titre=~s/&#38;#39;/'/g;
    $titre=~s/&#38;#34;/"/g;
    $titre=~s/$/\./g;
	$titre=~s/\.+$/\./g;
    return $titre,$description;
}
