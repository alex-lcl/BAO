#/usr/bin/perl
<<DOC; 
Votre Nom : Alexandra LI COMBEAU LONGUET
 usage : perl BAO2_parcours-arborescence-fichiers-regexp-global.pl repertoire-a-parcourir rubrique
 Le programme prend en entrée le nom du répertoire-racine contenant les fichiers
 à traiter et le nom de la rubrique à traiter parmi ces fichiers
DOC
#-----------------------------------------------------------
use strict;
use utf8;
use Timer::Simple;
# on instancie un timer commencant à 0.0s par défaut
my $t = Timer::Simple->new();
# on lance le timer
$t->start;
#-----------------------------------------------------------
my $rep="$ARGV[0]";
my $rubrique ="$ARGV[1]";
# on s'assure que le nom du répertoire ne se termine pas par un "/"
$rep=~ s/[\/]$//;
open(OUT,">:encoding(utf8)","sortie-slurp_$rubrique.txt");
open(OUTXML,">:encoding(utf8)","sortiexml-slurp_$rubrique.xml");
open(OUTUDPIPE,">:encoding(utf8)","sortieudpipe-slurp_$rubrique.txt");
print OUTXML "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n";
print OUTXML "<corpus2020>\n";
my %dico_des_titres=();
my $numberItem=0;
my $i=0;
#----------------------------------------
&parcoursarborescencefichiers($rep);	#recurse!
#----------------------------------------
print OUTXML "</corpus2020>\n";
close OUT;
close OUTXML;
close OUTUDPIPE;
#----------------------------------------
&etiquetageTT;
&etiquetageUD;
#----------------------------------------
print "Nb item : $numberItem \n";
# temps écoulé depuis le lancement du programme
print "time so far: ", $t->elapsed, " seconds\n";
exit;
#----------------------------------------------
sub parcoursarborescencefichiers {
    my $path = shift(@_);
    opendir(DIR, $path) or die "can't open $path: $!\n";
    my @files = readdir(DIR);
    closedir(DIR);
    foreach my $file (@files) {
		next if $file =~ /^\.\.?$/;
		$file = $path."/".$file;
		if (-d $file) {
			&parcoursarborescencefichiers($file);	#recurse!
		}
		if (-f $file) {
			if ($file =~/$rubrique.+xml$/) {
				print $i++," Traitement de : ",$file,"\n";
				open(FIC,"<:encoding(utf8)",$file);
				$/=undef;     #ou $\=""
				my $textelu=<FIC>;
				close FIC;
				my $texte2tag="";
				while ($textelu=~/<item>.*?<title>(.+?)<\/title>.+?<description>(.+?)<\/description>/sg) {
					my $titre=$1;
					my $description=$2;
					$numberItem++;
					if (!(exists $dico_des_titres{$titre})) { 
						$dico_des_titres{$titre}=$description ;
						# Appel du sous-programme de nettoyage 
						($titre,$description)=&nettoyage($titre,$description);
						# Ecriture des résultats en sorties
						print OUT $titre,"\n";
						print OUT $description,"\n";
						print OUT "\n";
						# pré-étiquetage avant treetagger : tokenization --------------
						my ($titre_etiket,$description_etiket)=&preetiquetage($titre,$description);
						#--------------------------------------
						print OUTXML "<item><titre>\n$titre_etiket\n</titre><description>\n$description_etiket\n</description></item>\n";
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
	
	$titre=~s/&amp/&amp;/g;
	$description=~s/&amp/&amp;/g;
    return $titre,$description;
}
#----------------------------------------------
sub preetiquetage {
    my $titre = $_[0];
    my $description = $_[1];
	#-----------------etiquetage titre-----------------------------
	open (ETI, ">:encoding(utf8)", "temporaire.txt");
    print ETI $titre;
    close ETI;
    system ("perl -f ./distrib-treetagger/tokenise-utf8.pl temporaire.txt > test.txt.pos");
    open (TEMP, "<:encoding(utf8)", "test.txt.pos");
    $/=undef;
    my $titre_etik_xml=<TEMP>;
    close TEMP;
	#-----------------etiquetage description-----------------------------
    open (ETI, ">:encoding(utf8)", "temporaire.txt");
    print ETI $description;
    close ETI;
    system ("perl -f ./distrib-treetagger/tokenise-utf8.pl temporaire.txt > test.txt.pos");
    open (TEMP, "<:encoding(utf8)", "test.txt.pos");
    $/=undef;
    my $description_etik_xml=<TEMP>;
    close TEMP;
    return $titre_etik_xml,$description_etik_xml;
}

#----------------------------------------------
sub etiquetageTT {
    system ("perl -f ./distrib-treetagger/tokenise-utf8.pl sortiexml-slurp_$rubrique.xml | ./distrib-treetagger/tree-tagger ./distrib-treetagger/french-utf8.par -token -lemma -no-unknown -sgml > sortiexml-slurp_TT_$rubrique.txt");
    system ("perl ./distrib-treetagger/treetagger2xml-utf8.pl sortiexml-slurp_TT_$rubrique.txt utf8"); 
}

#-----------------------------------------------
sub etiquetageUD {
	# Etiquetage avec udpipe --------------
	# lancer udpipe : distrib-udpipe-1.2.0-bin
	system("./distrib-udpipe-1.2.0-bin/udpipe-1.2.0-bin/bin-linux64/udpipe --tokenize --tokenizer=presegmented --tag --parse ./distrib-udpipe-1.2.0-bin/modeles/french-gsd-ud-2.5-191206.udpipe sortie-slurp_$rubrique.txt > sortieudpipe-slurp_$rubrique.txt");
	system("perl ./distrib-udpipe-1.2.0-bin/udpipe2xml-version-sans-titrevsdescription-v2.pl sortieudpipe-slurp_$rubrique.txt");
}

