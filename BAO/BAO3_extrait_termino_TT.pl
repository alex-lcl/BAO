open my $termino, "$ARGV[1]";
@patrons=<$termino>;
close $termino;
#my $suitedepos="VERB DET NOUN";

open my $entree, "$ARGV[0]";
@pos=();
@token=();
while (my $ligne=<$entree>) {

	next if $ligne=~m/<?xml version="1.0" encoding="utf-8" ?>|<corpus2020>|<item>|<titre>|<description>/ ;
	#print $ligne;
	$ligne=~s/(<\/corpus2020>|<\/item>|<\/titre>|<\/description>)\r?\n//g;
	if ($ligne ne "") {
	my @ligne = split /\t/, $ligne;
	push @pos, $ligne[1];
	push @token, $ligne[0];
	#my $rep=<STDIN>;
	}

	else {
	#print "je traite les listes\n";
	#print "@pos\n";
	#print "@token\n";
	foreach my $suitedepos (@patrons) {
		$long=0;
		$suitedepos=~s/\r?\n//g;
		while ($suitedepos=~/ /g) {$long++}
		$i=0;
		foreach my $element (@pos) {
			$i++;
			#print $element;
			if ($suitedepos =~/^$element/) {
			#print "presence de $element, je cherche toute la séquence de $i et ensuite sur $long caractères\n";
			$suite="";		
			for ($j=$i-1;$j<=$long+$i-1;$j++) {$suite=$suite.$pos[$j]." ";}
			#print "==>$suite<==\n";
			# print "==>$suitedepos<==\n";
			if ($suite=~/$suitedepos/) {
				#print "MATCH de $i à $j\n";
				#print "@token[$i-1..$j-1]\n";
				$extract = join(" ", @token[$i-1..$j-1]);
				$dict{lc($extract)}++;
				print "$suitedepos : $extract\n";
					}
				}
			}
		}
	#my $rep=<STDIN>;
	@pos=();
	@token=();
	}
}

# foreach my $toto (sort {${b} <=> $dict{$a} } keys %dict)
	# {print "$toto : %dict{$toto}\n";}