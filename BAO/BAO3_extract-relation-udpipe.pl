#!/usr/bin/perl
#----------------------------------------------------------------------------------
# MODE D EMPLOI : perl BAO3_extract-relation-udpipe.pl sortieudpipe-slurp_3210.txt.xml "obj"
# En entrée : sortie UDPIPE formatée en XML + une relation syntaxique
# En sortie la liste triée des couples Gouv,Dep en relation
#----------------------------------------------------------------------------------
use strict;
use utf8;
binmode STDOUT, ':utf8';
#-------------------------------------------------------------------------------------
my $rep="$ARGV[0]";
my $relation="$ARGV[1]";
my %dicoRelation=();
#-------------------------------------------------------------------------------------
# on découpe le texte par phrase (liste d'items annotés et potentiellement dépendants)
$/="</p>"; 			
open my $IN ,"<:encoding(utf8)","$ARGV[0]";
while (my $phrase=<$IN>) {
	#-------------------------------------------------------------------------------------
	# on traite chaque "paragraphe" en le decoupant "items"
	my @LIGNES=split(/\n/,$phrase);
	for (my $i=0;$i<=$#LIGNES;$i++) {
		# si la ligne lue contient la relation, on ira chercher le dep puis le gouv
		if ($LIGNES[$i]=~/<item><a>([^<]+)<\/a><a>([^<]+)<\/a><a>[^<]+<\/a><a>[^<]+<\/a><a>[^<]+<\/a><a>[^<]+<\/a><a>([^<]+)<\/a><a>[^<]*$relation[^<]*<\/a><a>[^<]+<\/a><a>[^<]+<\/a><\/item>/i) {
			my $posDep=$1;
			my $posGouv=$3;
			my $formeDep=$2;
			# soit le gouv est avant le dep, soit après...
			if ($posDep > $posGouv) {
				for (my $k=0;$k<$i;$k++) {
					if ($LIGNES[$k]=~/<item><a>$posGouv<\/a><a>([^<]+)<\/a><a>[^<]+<\/a><a>[^<]+<\/a><a>[^<]+<\/a><a>[^<]+<\/a><a>[^<]+<\/a><a>[^<]+<\/a><a>[^<]+<\/a><a>[^<]+<\/a><\/item>/) {
						my $formeGouv=$1;
						$dicoRelation{"$formeGouv $formeDep"}++;
					}
				}
			}
			else {
				for (my $k=$i+1;$k<=$#LIGNES;$k++) {
					if ($LIGNES[$k]=~/<item><a>$posGouv<\/a><a>([^<]+)<\/a><a>[^<]+<\/a><a>[^<]+<\/a><a>[^<]+<\/a><a>[^<]+<\/a><a>[^<]+<\/a><a>[^<]+<\/a><a>[^<]+<\/a><a>[^<]+<\/a><\/item>/) {
						my $formeGouv=$1;
						$dicoRelation{"$formeGouv $formeDep"}++;
					}
				}
			}
		}
	}
}
close ($IN);
# on imprime la liste des couples Gouv,Dep et leur fréquence...
foreach my $relation (sort {$dicoRelation{$b}<=>$dicoRelation{$a}} (keys %dicoRelation)) {
	print "$relation\t$dicoRelation{$relation}\n";
}
